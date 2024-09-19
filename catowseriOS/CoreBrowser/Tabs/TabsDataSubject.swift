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
@MainActor
@Observable
public final class TabsDataSubject {
    /// An identifier of the selected tab
    public var selectedTabId: UUID
    /// The amount of tabs
    public var tabsCount: Int {
        tabs.count
    }
    /// An array of all tabs
    public var tabs: [Tab] = []
    /// Index of the replaced tab, have to use separate property because tabs array can't provide that info
    public var replacedTabIndex: Int?
    
    public init(
        _ positioning: TabsStates,
        _ tabs: [Tab] = []
    ) {
        self.selectedTabId = positioning.defaultSelectedTabId
        self.tabs = tabs
    }
}
