//
//  TabsServiceCommand.swift
//  CoreBrowser
//
//  Created by Andrey Ermoshin on 20.01.2024.
//  Copyright © 2024 Cotton (former Catowser). All rights reserved.
//

import Foundation

/**
 Tabs data service commands for the Command design pattern.
 Each command case can carry the input data.
 */
public enum TabsServiceCommand: Sendable {
    case getTabsCount
    case getSelectedTabId
    case getAllTabs
    case addTab(Tab)
    case closeTab(Tab)
    case closeTabWithId(UUID)
    case closeAll
    case selectTab(Tab)
    case replaceSelectedContent(Tab.ContentType)
    case updateSelectedTabPreview(Data?)
}
