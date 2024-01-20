//
//  SelectedTabUseCaseImpl.swift
//  CoreBrowser
//
//  Created by Andrey Ermoshin on 04.01.2024.
//  Copyright © 2024 andreiermoshin. All rights reserved.
//

import Foundation

public final class SelectedTabUseCaseImpl: SelectedTabUseCase {
    private let tabsDataService: TabsDataService
    
    init(_ tabsDataService: TabsDataService) {
        self.tabsDataService = tabsDataService
    }
    
    /// Returns currently selected tab.
    public func selectedTab() async throws -> Tab {
        guard await selectedId != positioning.defaultSelectedTabId else {
            throw TabsListError.notInitializedYet
        }
        guard let tabTuple = await tabs.element(by: selectedId) else {
            throw TabsListError.selectedNotFound
        }
        return tabTuple.tab
    }
    
    /// Returns index of selected tab
    public func selectedIndex() async throws -> Int {
        guard let tabTuple = await tabs.element(by: selectedId) else {
            throw TabsListError.notInitializedYet
        }
        return tabTuple.index
    }
}
