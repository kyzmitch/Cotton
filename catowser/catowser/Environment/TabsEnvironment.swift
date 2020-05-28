//
//  TabsEnvironment.swift
//  catowser
//
//  Created by Andrei Ermoshin on 5/28/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import CoreBrowser

final class TabsEnvironment {
    static let shared: TabsEnvironment = .init()
    
    let cachedTabsManager: TabsListManager
    
    private init() {
        cachedTabsManager = .init(storage: TabsCacheProvider.shared,
                                  positioning: DefaultTabProvider.shared)
    }
}

extension TabsListManager {
    static var shared: TabsListManager {
        return TabsEnvironment.shared.cachedTabsManager
    }
}
