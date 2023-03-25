//
//  TabsStoragable.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 5/28/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import ReactiveSwift
import AutoMockable

public protocol TabsStoragable: AutoMockable {
    /// Defines human redable name for Int if it is describes index.
    /// e.g. implementation could use Index type instead.
    typealias TabIndex = Int

    /// The identifier of selected tab.
    func fetchSelectedTabId() -> SignalProducer<UUID, TabStorageError>
    func fetchSelectedTabId() async throws -> UUID
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
    func fetchAllTabs() async throws -> [Tab]

    /// Adds a tab to storage
    ///
    /// - Parameter tab: The tab object to be added.
    func add(tab: Tab, andSelect select: Bool) -> SignalProducer<Tab, TabStorageError>
    func add(_ tab: Tab, select: Bool) async throws -> Tab
    
    /// Updates tab content
    ///
    /// - Parameter tab: The tab object to be updated. Usually only tab content needs to be updated.
    func update(tab: Tab) -> SignalProducer<Tab, TabStorageError>
    
    /// Removes tab from cache
    ///
    /// - Parameter tab: The tab object to be removed from databse.
    func remove(tab: Tab) -> SignalProducer<Tab, TabStorageError>
    
    /// Removes all the tabs for current session
    func remove(tabs: [Tab]) -> SignalProducer<[Tab], TabStorageError>
}
