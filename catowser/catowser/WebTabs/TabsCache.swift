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

/**
 Declare Tab storage type in host app instead of `CoreBrowser`
 to allow use app settings like default tab content which only can be stored in host app,
 because it can't be passed as an argument to Tabs manager since it is a singleton.
 Anyway, now it's not a singletone, since we're passing tabs store instance to it, but
 with environment class which holds reference to tabs list manager it's kind of singletone.
 */

final class TabsCacheProvider {
    static let shared = TabsCacheProvider()
    private init() {
        queue = DispatchQueue(label: .queueNameWith(suffix: "tabsCache"))
    }

    private lazy var scheduler: QueueScheduler = {
        let s = QueueScheduler(targeting: queue)
        return s
    }()
    private let queue: DispatchQueue
}

extension TabsCacheProvider: TabsStorage {
    func fetchSelectedIndex() -> SignalProducer<Int, TabStorageError> {
        return SignalProducer<Int, TabStorageError>.init(value: 0).start(on: scheduler)
    }

    func select(tab: Tab) -> Int? {
        // TODO: implement, temporary code
        return nil
    }

    func fetch() -> SignalProducer<[Tab], TabStorageError> {
        let producer = SignalProducer<[Tab], TabStorageError>.init { (observer, _ /* lifetime */) in
            let tab = Tab(contentType: .topSites /* DefaultTabProvider.shared.contentState */, selected: true)
            observer.send(value: [tab])
            observer.sendCompleted()
        }
        return producer.start(on: scheduler)
    }

    func add(tab: Tab) {
        // TODO: add code
    }
}
