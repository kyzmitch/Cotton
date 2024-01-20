//
//  TabsServiceDataOutput.swift
//  CoreBrowser
//
//  Created by Andrey Ermoshin on 20.01.2024.
//  Copyright © 2024 andreiermoshin. All rights reserved.
//

import Foundation

public enum TabsServiceDataOutput {
    case tabsCount(Int)
    case selectedTabId(UUID)
    case allTabs([Tab])
}
