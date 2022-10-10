//
//  TabsStatesMocks.swift
//  CoreBrowserTests
//
//  Created by Andrei Ermoshin on 10/9/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CoreBrowser

struct MockedTabsStates: TabsStates {
    init() {}
    
    let addPosition: AddedTabPosition = .listEnd
    
    let contentState: Tab.ContentType = .favorites
    
    let addSpeed: TabAddSpeed = .immediately
    
    let defaultSelectedTabId: UUID = .notPossibleId
}

extension UUID {
    static let notPossibleId: UUID = .init(uuid: (0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1))
}
