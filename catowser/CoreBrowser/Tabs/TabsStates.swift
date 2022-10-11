//
//  TabsStates.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 5/30/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation

// sourcery: AutoMockable
public protocol TabsStates {
    var addPosition: AddedTabPosition { get }
    var contentState: Tab.ContentType { get }
    var addSpeed: TabAddSpeed { get }
    var defaultSelectedTabId: UUID { get }
}
