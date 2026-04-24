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

    public init(_ tabsDataService: any TabsDataServiceProtocol) {
        self.tabsDataService = tabsDataService
    }

    public func execute(input tab: CoreBrowser.Tab) async throws -> Tab.ID? {
        #warning("TODO: https://github.com/kyzmitch/Cotton/issues/92")
        let serviceData = await tabsDataService.sendCommand(.closeTab(tab), nil)
        guard case let .finished(result) = serviceData.tabClosed else {
            throw AppError.commandNotFinishedYet
        }
        switch result {
        case .failure(let error):
            throw error
        case .success(let newSelectedId):
            return newSelectedId
        }
    }
}
