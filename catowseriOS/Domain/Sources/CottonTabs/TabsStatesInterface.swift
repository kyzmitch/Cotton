//
//  TabsStatesInterface.swift
//  CottonDataServices
//
//  Created by Andrei Ermoshin on 5/30/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import CoreBrowser
import AutoMockable

/// Tab states interface.
///
/// Used only outside of this module in several places.
public protocol TabsStatesInterface: AutoMockable, Sendable {
    /// Determines how to add a new tab
    var addPosition: AddedTabPosition { get async }
    /// Determines default tab content state
    var contentState: Tab.ContentType { get async }
    /// Determines tab animation speed
    var addSpeed: TabAddSpeed { get }
    /// Default tab id when selected when it is not synced
    var defaultSelectedTabId: Tab.ID { get }
}
