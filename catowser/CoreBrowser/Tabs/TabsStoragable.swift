//
//  TabsStoragable.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 5/28/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import ReactiveSwift

public protocol TabsStoragable {
    /// Defines human redable name for Int if it is describes index.
    /// e.g. implementation could use Index type instead.
    typealias TabIndex = Int

    /// The identifier of selected tab.
    func fetchSelectedTabId() -> SignalProducer<UUID, TabStorageError>
    /// Changes selected tab only if it is presented in storage.
    ///
    /// - Parameter tab: The tab object to be selected.
    ///
    /// - Returns: An identifier of the selected tab.
    func select(tab: Tab) -> SignalProducer<UUID, TabStorageError>

    /// Loads tabs data from storage.
    ///
    /// - Returns: A producer with tabs array or error.
    func fetchAllTabs() -> SignalProducer<[Tab], TabStorageError>

    /// Adds a tab to storage
    ///
    /// - Parameter tab: The tab object to be added.
    func add(tab: Tab) -> SignalProducer<Void, TabStorageError>
}
