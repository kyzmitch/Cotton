//
//  ReadTabsUseCaseImpl.swift
//  CoreBrowser
//
//  Created by Andrey Ermoshin on 04.01.2024.
//  Copyright © 2024 andreiermoshin. All rights reserved.
//

import Foundation

public final class ReadTabsUseCaseImpl: ReadTabsUseCase {
    private let tabsDataService: TabsDataService
    
    init(_ tabsDataService: TabsDataService) {
        self.tabsDataService = tabsDataService
    }
    
    public var tabsCount: Int {
        get async {
            tabs.count
        }
    }
    
    public var selectedId: UUID {
        get async {
            selectedTabIdentifier
        }
    }
    
    public var allTabs: [Tab] {
        get async {
            tabs
        }
    }
}
