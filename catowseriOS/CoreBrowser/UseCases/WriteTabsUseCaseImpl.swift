//
//  WriteTabsUseCaseImpl.swift
//  CoreBrowser
//
//  Created by Andrey Ermoshin on 04.01.2024.
//  Copyright © 2024 andreiermoshin. All rights reserved.
//

import Foundation

public final class WriteTabsUseCaseImpl: WriteTabsUseCase {
    private let tabsDataService: TabsDataService
    
    public init(_ tabsDataService: TabsDataService) {
        self.tabsDataService = tabsDataService
    }
    
    public func add(tab: Tab) async {
        _ = await tabsDataService.sendCommand(.addTab(tab))
    }
    
    public func close(tab: Tab) async {
        _ = await tabsDataService.sendCommand(.closeTab(tab))
    }
    
    public func closeAll() async {
        _ = await tabsDataService.sendCommand(.closeAll)
    }
    
    public func select(tab: Tab) async {
        _ = await tabsDataService.sendCommand(.selectTab(tab))
    }
    
    public func replaceSelected(_ tabContent: Tab.ContentType) async {
        _ = await tabsDataService.sendCommand(.replaceSelectedContent(tabContent))
    }
}
