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
 Declare Tab storage type in host app instead of `CoreBrowser`
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
    func fetchSelectedIndex() -> SignalProducer<UInt, TabStorageError> {
        return tabsDbResource.selectedTabIndex()
            .mapError({ (resourceError) -> TabStorageError in
                return .dbResourceError(resourceError)
            }).start(on: scheduler)
    }

    func select(tab: Tab) -> SignalProducer<Int, TabStorageError> {
        return SignalProducer<Int, TabStorageError>.init(value: 0).start(on: scheduler)
    }

    func fetchAllTabs() -> SignalProducer<[Tab], TabStorageError> {
        return tabsDbResource.tabsFromLastSession()
            .mapError({ (resourceError) -> TabStorageError in
                return .dbResourceError(resourceError)
            }).start(on: scheduler)
    }

    func add(tab: Tab) {
        // TODO: add code
    }
}
