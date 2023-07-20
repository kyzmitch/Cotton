//
//  TabsResource.swift
//  catowser
//
//  Created by Andrei Ermoshin on 9/28/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import ReactiveSwift
import CoreBrowser
import CoreData

fileprivate extension String {
    static let threadName = "tabsStore"
}

final class TabsResource {
    private var dbClient: TabsDBClient
    
    /// Needs to be checked on every access to `dbClient` to not use wrong context
    /// functions can return empty data if it's not initialized state
    private var isStoreInitialized = false
    
    private let queue: DispatchQueue = .init(label: .queueNameWith(suffix: .threadName))
    
    private lazy var scheduler = QueueScheduler(targeting: queue)
    
    /// Creates an instance of TabsResource which is a wrapper around CoreData Store class
    ///
    /// - Parameters:
    ///   - temporaryContext: Temporary core data context to be able to compile init.
    ///   For valid instance we must create Core Data context on
    ///   specific thread to keep using it only with this thread.
    ///   - privateContextCreator: We have to call this closure on specific thread and
    ///    use same thread for any other usages of this context.
    init(temporaryContext: NSManagedObjectContext,
         privateContextCreator: @escaping () -> NSManagedObjectContext?) {
        // Creating temporary instance to be able to use background thread
        // to properly create private CoreData context
        let dummyStore: TabsDBClient = .init(temporaryContext)
        dbClient = dummyStore
        queue.async { [weak self] in
            guard let self = self else {
                fatalError("Tabs Resource is nil in init")
            }
            guard let correctContext = privateContextCreator() else {
                fatalError("Tabs Resource closure returns no private CoreData context")
            }
            self.dbClient = .init(correctContext)
            self.isStoreInitialized = true
        }
    }
    
    /// Saves the tab in DB without selecting it
    func remember(tab: Tab, andSelect select: Bool) -> SignalProducer<Tab, TabResourceError> {
        let producer: SignalProducer<Tab, TabResourceError> = .init { [weak self] (observer, _) in
            guard let self = self else {
                observer.send(error: .zombieSelf)
                return
            }
            guard self.isStoreInitialized else {
                observer.send(error: .storeNotInitializedYet)
                return
            }
            
            do {
                try self.dbClient.insert(tab: tab)
                if select {
                    try self.dbClient.select(tab: tab)
                }
                observer.send(value: tab)
                observer.sendCompleted()
            } catch {
                observer.send(error: .insertError(error))
            }
        }
        
        return producer.observe(on: scheduler)
    }
    
    /// Updates tab content if tab with same identifier was found in DB or creates completely new tab
    func update(tab: Tab) throws -> Tab {
        guard self.isStoreInitialized else {
            throw TabResourceError.storeNotInitializedYet
        }
        
        do {
            try self.dbClient.update(tab: tab)
            return tab
        } catch {
            throw TabResourceError.insertError(error)
        }
    }
    
    /// Removes the tab from DB
    func forget(tab: Tab) -> SignalProducer<Tab, TabResourceError> {
        let producer: SignalProducer<Tab, TabResourceError> = .init { [weak self] (observer, _) in
            guard let self = self else {
                observer.send(error: .zombieSelf)
                return
            }
            guard self.isStoreInitialized else {
                observer.send(error: .storeNotInitializedYet)
                return
            }
            
            do {
                try self.dbClient.remove(tab: tab)
                observer.send(value: tab)
                observer.sendCompleted()
            } catch {
                observer.send(error: .deleteError(error))
            }
            
        }
        return producer.observe(on: scheduler)
    }
    
    /// Remove all the tabs
    func forget(tabs: [Tab]) -> SignalProducer<[Tab], TabResourceError> {
        let producer: SignalProducer<[Tab], TabResourceError> = .init { [weak self] (observer, _) in
            guard let self = self else {
                observer.send(error: .zombieSelf)
                return
            }
            guard self.isStoreInitialized else {
                observer.send(error: .storeNotInitializedYet)
                return
            }
            
            do {
                try self.dbClient.removeAll(tabs: tabs)
                observer.send(value: tabs)
                observer.sendCompleted()
            } catch {
                observer.send(error: .deleteError(error))
            }
            
        }
        return producer.observe(on: scheduler)
    }
    
    /// Remembers tab identifier as selected one
    func selectTab(_ tab: Tab) async throws {
        guard self.isStoreInitialized else {
            throw TabResourceError.storeNotInitializedYet
        }
        
        do {
            try await self.dbClient.select(tab: tab)
        } catch {
            throw TabResourceError.selectedTabId(error)
        }
    }
}

extension TabsResource {
    /// Gets all tabs recorded in DB. Currently there is only one session, but later
    /// it should be possible to store and read tabs from different sessions like
    /// private browser session tabs & usual tabs.
    func tabsFromLastSession() async throws -> [Tab] {
        guard isStoreInitialized else {
            throw TabResourceError.storeNotInitializedYet
        }
        return try await dbClient.fetchAllTabs()
    }
    
    func remember(tab: Tab, andSelect select: Bool) async throws -> Tab {
        guard isStoreInitialized else {
            throw TabResourceError.storeNotInitializedYet
        }
        try await dbClient.insert(tab: tab)
        if select {
            try await dbClient.select(tab: tab)
        }
        return tab
    }
    
    /// Gets an identifier of a selected tab or an error if no tab is present which isn't possible
    /// at least blank tab should be present.
    func selectedTabId() async throws -> UUID {
        guard isStoreInitialized else {
            throw TabResourceError.storeNotInitializedYet
        }
        return try await dbClient.selectedTabId()
    }
}
