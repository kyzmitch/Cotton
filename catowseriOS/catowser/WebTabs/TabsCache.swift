//
//  TabsCache.swift
//  catowser
//
//  Created by Andrei Ermoshin on 28/01/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import ReactiveSwift
import CoreBrowser
import CoreData

fileprivate extension String {
    static let threadName = "tabsCache"
}

/**
 Declaring Tab storage type in host app instead of `CoreBrowser`
 to allow use app settings like default tab content which only can be stored in host app,
 because it can't be passed as an argument to Tabs manager since it is a singleton.
 Anyway, now it's not a singletone, since we're passing tabs store instance to it, but
 with environment class which holds reference to tabs list manager it's kind of singletone.
 */
final class TabsCacheProvider {
    private lazy var scheduler: QueueScheduler = {
        let schedulerOnQueue = QueueScheduler(targeting: queue)
        return schedulerOnQueue
    }()
    private let queue: DispatchQueue
    private let tabsDbResource: TabsResource
    
    init(temporaryContext: NSManagedObjectContext,
         privateContextCreator: @escaping () -> NSManagedObjectContext?) {
        queue = DispatchQueue(label: .queueNameWith(suffix: .threadName))
        tabsDbResource = .init(temporaryContext: temporaryContext,
                               privateContextCreator: privateContextCreator)
    }
}

extension TabsCacheProvider: TabsStoragable {
    func select(tab: Tab) async throws -> UUID {
        do {
            try await tabsDbResource.selectTab(tab)
            return tab.id
        } catch {
            throw TabStorageError.dbResourceError(error)
        }
    }

    func add(tab: Tab, andSelect select: Bool) -> SignalProducer<Tab, TabStorageError> {
        return tabsDbResource
            .remember(tab: tab, andSelect: select)
            .mapError({ (resourceError) -> TabStorageError in
                return .dbResourceError(resourceError)
            }).start(on: scheduler)
    }
    
    func update(tab: Tab) throws -> Tab {
        do {
            return try tabsDbResource.update(tab: tab)
        } catch {
            throw TabStorageError.dbResourceError(error)
        }
    }
    
    func remove(tab: Tab) -> SignalProducer<Tab, TabStorageError> {
        return tabsDbResource
            .forget(tab: tab)
            .mapError({ (resourceError) -> TabStorageError in
                return .dbResourceError(resourceError)
            }).start(on: scheduler)
    }
    
    func remove(tabs: [Tab]) -> SignalProducer<[Tab], TabStorageError> {
        return tabsDbResource
            .forget(tabs: tabs)
            .mapError({ (resourceError) -> TabStorageError in
                return .dbResourceError(resourceError)
            }).start(on: scheduler)
    }
    
    func fetchAllTabs() async throws -> [Tab] {
        try await tabsDbResource.tabsFromLastSession()
    }
    
    func add(_ tab: Tab, select: Bool) async throws -> Tab {
        try await tabsDbResource.remember(tab: tab, andSelect: select)
    }
    
    func fetchSelectedTabId() async throws -> UUID {
        try await tabsDbResource.selectedTabId()
    }
}
