//
//  CloseTabUseCase.swift
//  CoreBrowser
//
//  Created by Andrey Ermoshin on 04.01.2024.
//  Copyright © 2024 Cotton (former Catowser). All rights reserved.
//

import AutoMockable
import CoreBrowser
import CottonTabs
import BaseUseCaseKit

/// Close tab use case.
public protocol CloseTabUseCase: CoreUseCase, AutoMockable, Sendable {
    /// Close a tab
    ///
    /// - Parameter tab: A tab to close
    /// - Returns new selected tab identifier if we closed selected tab and auto-selection happened
    func execute(input: CoreBrowser.Tab) async throws -> Tab.ID?
}

public final class CloseTabUseCaseImpl: CloseTabUseCase {
    private let tabsDataService: any TabsDataServiceProtocol
    private let selectionStrategy: TabSelectionStrategy
    private let selectTabUseCase: any SelectTabUseCase
    private let addTabUseCase: any AddTabUseCase
    private let positioning: TabsStatesInterface

    public init(
        _ tabsDataService: any TabsDataServiceProtocol,
        _ selectionStrategy: TabSelectionStrategy,
        _ selectTabUseCase: any SelectTabUseCase,
        _ addTabUseCase: any AddTabUseCase,
        _ positioning: TabsStatesInterface
    ) {
        self.tabsDataService = tabsDataService
        self.selectionStrategy = selectionStrategy
        self.selectTabUseCase = selectTabUseCase
        self.addTabUseCase = addTabUseCase
        self.positioning = positioning
    }

    public func execute(input tab: CoreBrowser.Tab) async throws -> Tab.ID? {
        let tabsBefore = try await readAllTabs()
        let selectedIdBefore = try await readSelectedTabId()
        guard let closedTabIndex = tabsBefore.firstIndex(where: { $0.id == tab.id }) else {
            throw TabsListError.closingNonExistingTab
        }
        let closedTabWasSelected = tab.id == selectedIdBefore
        let selectedIndexBefore = tabsBefore.firstIndex(where: { $0.id == selectedIdBefore }) ?? 0

        let serviceData = await tabsDataService.sendCommand(.closeTab(tab), nil)
        guard case let .finished(result) = serviceData.tabClosed else {
            throw AppError.commandNotFinishedYet
        }
        switch result {
        case .failure(let error):
            throw error
        case .success:
            break
        }

        if tabsBefore.count == 1 {
            return try await recoverLastTab()
        }

        let context = TabsIndexSelectionSnapshot(
            collectionLastIndex: tabsBefore.count - 1,
            currentlySelectedIndex: selectedIndexBefore
        )
        let strategyIndex = await selectionStrategy.autoSelectedIndexAfterTabRemove(
            context: context,
            removedIndex: closedTabIndex
        )
        let tabsAfter = try await readAllTabs()

        if let strategyIndex {
            guard strategyIndex >= 0, strategyIndex < tabsAfter.count else {
                throw TabsListError.failToFindNewSelectedTab
            }
            let newSelected = tabsAfter[strategyIndex]
            try await selectTabUseCase.execute(input: newSelected)
            return newSelected.id
        }

        // Nearby strategy returns nil when closing the selected non-last tab:
        // same index now refers to a different tab — select it explicitly.
        if closedTabWasSelected {
            let index = min(closedTabIndex, tabsAfter.count - 1)
            guard index >= 0, index < tabsAfter.count else {
                throw TabsListError.failToFindNewSelectedTab
            }
            let newSelected = tabsAfter[index]
            try await selectTabUseCase.execute(input: newSelected)
            return newSelected.id
        }

        return nil
    }

    private func recoverLastTab() async throws -> Tab.ID {
        let contentState = await positioning.contentState
        let newTab = CoreBrowser.Tab(contentType: contentState)
        try await addTabUseCase.execute(input: newTab)
        return newTab.id
    }

    private func readAllTabs() async throws -> [CoreBrowser.Tab] {
        let serviceData = await tabsDataService.sendCommand(.getAllTabs, nil)
        guard case let .finished(result) = serviceData.allTabs else {
            throw AppError.commandNotFinishedYet
        }
        return try result.get()
    }

    private func readSelectedTabId() async throws -> Tab.ID {
        let serviceData = await tabsDataService.sendCommand(.getSelectedTabId, nil)
        guard case let .finished(result) = serviceData.selectedTabId else {
            throw AppError.commandNotFinishedYet
        }
        return try result.get()
    }
}
