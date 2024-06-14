//
//  ReadTabsUseCaseImpl.swift
//  CoreBrowser
//
//  Created by Andrey Ermoshin on 04.01.2024.
//  Copyright © 2024 Cotton (former Catowser). All rights reserved.
//

import Foundation

public final class ReadTabsUseCaseImpl: ReadTabsUseCase {
    private let tabsDataService: TabsDataService
    private let positioning: TabsStates

    public init(_ tabsDataService: TabsDataService, _ positioning: TabsStates) {
        self.tabsDataService = tabsDataService
        self.positioning = positioning
    }

    public var tabsCount: Int {
        get async {
            let response = await tabsDataService.sendCommand(.getTabsCount)
            guard case .tabsCount(let value) = response else {
                return 1
            }
            return value
        }
    }

    public var selectedId: UUID {
        get async {
            let response = await tabsDataService.sendCommand(.getSelectedTabId)
            guard case .selectedTabId(let value) = response else {
                return positioning.defaultSelectedTabId
            }
            return value
        }
    }

    public var allTabs: [CoreBrowser.Tab] {
        get async {
            let response = await tabsDataService.sendCommand(.getAllTabs)
            guard case .allTabs(let value) = response else {
                return []
            }
            return value
        }
    }
}
