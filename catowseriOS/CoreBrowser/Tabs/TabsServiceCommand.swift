//
//  TabsServiceCommand.swift
//  CoreBrowser
//
//  Created by Andrey Ermoshin on 20.01.2024.
//  Copyright © 2024 andreiermoshin. All rights reserved.
//

import UIKit

public enum TabsServiceCommand {
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
