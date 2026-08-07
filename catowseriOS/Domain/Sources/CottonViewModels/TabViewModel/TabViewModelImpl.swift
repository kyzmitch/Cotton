//
//  TabViewModelImpl.swift
//  CottonViewModels
//
//  Created by Andrei Ermoshin on 7/22/23.
//  Copyright © 2023 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation
import CottonBase
import CoreBrowser
import FeatureFlagsKit
import CottonUseCases
import CottonTabs
import ViewModelKit

/// Tab view model implementation on ViewModelKit.
@MainActor final class TabViewModelImpl: TabViewModel {
    private var tab: CoreBrowser.Tab
    private let readTabUseCase: any ReadSelectedTabIdUseCase
    private let closeTabUseCase: any CloseTabUseCase
    private let selectTabUseCase: any SelectTabUseCase
    private let appContext: TabViewModelContext
    private lazy var proxy = TabStateContextProxy(subject: self)

    init(
        _ tab: CoreBrowser.Tab,
        _ readTabUseCase: any ReadSelectedTabIdUseCase,
        _ closeTabUseCase: any CloseTabUseCase,
        _ selectTabUseCase: any SelectTabUseCase,
        _ context: TabViewModelContext,
        _ featureManager: FeatureManager.StateHolder
    ) {
        self.tab = tab
        self.readTabUseCase = readTabUseCase
        self.closeTabUseCase = closeTabUseCase
        self.selectTabUseCase = selectTabUseCase
        self.appContext = context
        _ = featureManager
        super.init(transitioning: TabStateTransitioning())
        // One-time seed: show title immediately (same UX as pre-kit init).
        state = .deSelected(tab.title, nil)

        Task {
            let observingType = await appContext.observingApiTypeValue
            if #available(iOS 17.0, *), observingType.isSystemObservation {
                startTabsObservation(await appContext.tabsSubject)
            }
        }
    }

    public override var context: Context? {
        proxy
    }

    // MARK: - private

    /// Loading of favicon doesn't depend on published state mutation.
    private func resolveFavicon(_ site: Site) async -> ImageSource? {
        if let hqImage = site.favicon() {
            return .image(hqImage)
        }
        let resolveNeeded = await appContext.isDohEnabled
        let url: URL?
        do {
            url = try await appContext.faviconURL(site, resolveNeeded)
        } catch {
            print("Fail to resolve favicon url: \(error)")
            url = nil
        }

        let source: ImageSource
        switch (url, site.favicon()) {
        case (let url?, nil):
            source = .url(url)
        case (nil, let image?):
            source = .image(image)
        case (let url?, let image?):
            source = .urlWithPlaceholder(url, image)
        default:
            return nil
        }
        return source
    }

    @available(iOS 17.0, *)
    @MainActor
    func startTabsObservation(_ tabsSubject: TabsDataSubject) {
        withObservationTracking {
            _ = tabsSubject.selectedTabId
        } onChange: {
            Task { [weak self] in
                await self?.handleSelectedTabChange(tabsSubject)
            }
        }
        withObservationTracking {
            _ = tabsSubject.replacedTabIndex
        } onChange: {
            Task { [weak self] in
                await self?.observeReplacedTab(tabsSubject)
            }
        }
    }

    @available(iOS 17.0, *)
    @MainActor
    func handleSelectedTabChange(_ tabsSubject: TabsDataSubject) async {
        let tabId = tabsSubject.selectedTabId
        guard let index = tabsSubject.tabs
                .firstIndex(where: { $0.id == tabId }) else {
            return
        }
        await tabDidSelect(index, tabsSubject.tabs[index].contentType, tabId)
    }

    @available(iOS 17.0, *)
    @MainActor
    private func observeReplacedTab(_ tabsSubject: TabsDataSubject) async {
        guard let index = tabsSubject.replacedTabIndex else {
            return
        }
        await tabDidReplace(tabsSubject.tabs[index], at: index)
    }
}

// MARK: - TabStateContext

extension TabViewModelImpl: TabStateContext {
    public var tabTitle: String {
        tab.title
    }

    public func isTabSelected() async throws -> Bool {
        let selectedTabId = try await readTabUseCase.execute()
        return tab.getVisualState(selectedTabId) == .selected
    }

    public func loadFavicon() async -> ImageSource? {
        guard let site = tab.site else {
            return nil
        }
        return await resolveFavicon(site)
    }

    public func closeTab() async {
        if let site = tab.site {
            _ = appContext.removeWebView(for: site)
        }
        do {
            _ = try await closeTabUseCase.execute(input: tab)
        } catch {
            print("Fail to close tab: \(error)")
        }
    }

    public func activateTab() async {
        print("\(#function): selected tab with id: \(tab.id)")
        do {
            try await selectTabUseCase.execute(input: tab)
        } catch {
            print("Fail to select tab: \(error.localizedDescription)")
        }
    }
}

// MARK: - TabsObserver

extension TabViewModelImpl: TabsObserver {
    public func tabDidSelect(
        _ index: Int,
        _ content: CoreBrowser.Tab.ContentType,
        _ identifier: UUID
    ) async {
        if tab.contentType != content {
            /// Need to reload favicon and title as well.
            /// Not sure if it is possible during simple select?
        }
        let isSelected = tab.id == identifier
        try? await sendAction(.applySelection(isSelected: isSelected))
    }

    public func tabDidReplace(
        _ tab: CoreBrowser.Tab,
        at index: Int
    ) async {
        guard self.tab.id == tab.id else {
            return
        }
        self.tab = tab
        let favicon: ImageSource?
        if let site = tab.site {
            favicon = await resolveFavicon(site)
        } else {
            favicon = nil
        }
        try? await sendAction(.applyReplace(title: tab.title, favicon: favicon))
    }
}
