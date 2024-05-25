//
//  TabsDataSubject.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 3/17/24.
//  Copyright © 2024 Cotton (Catowser). All rights reserved.
//

import Foundation
#if canImport(Observation)
import Observation
#endif

@available(iOS 17.0, *)
@Observable
public class TabsDataSubject {
    public var selectedTabId: UUID
    public var tabsCount: Int {
        tabs.count
    }
    public var tabs: [Tab] = []
    
    public init(_ positioning: TabsStates, _ tabs: [Tab] = []) {
        self.selectedTabId = positioning.defaultSelectedTabId
        self.tabs = tabs
        
    }
}
