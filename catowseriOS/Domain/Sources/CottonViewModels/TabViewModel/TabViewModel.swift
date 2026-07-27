//
//  TabViewModel.swift
//  catowser
//
//  Created by Andrey Ermoshin on 17.12.2024.
//  Copyright © 2024 Cotton (Catowser). All rights reserved.
//

import Combine
import CottonTabs

/// Tab view model interface
@MainActor public protocol TabViewModel: TabsObserver, AnyObject, Sendable {
    var state: TabViewState { get }
    var statePublisher: Published<TabViewState>.Publisher { get }

    func load()
    func close()
    func activate()
}
