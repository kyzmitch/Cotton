//
//  TabsCache.swift
//  catowser
//
//  Created by Andrei Ermoshin on 28/01/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import ReactiveSwift

public enum TabStorageError: Swift.Error {
    case unknown
}

public protocol TabsStorage {
    /// Defines human redable name for Int if it is describes index.
    /// e.g. implementation could use Index type instead.
    typealias TabIndex = Int

    /// The selected index. Should be presented anyway, so,
    /// storage must contain at least one tab and it is `blank` tab.
    func fetchSelectedIndex() -> SignalProducer<Int, TabStorageError>
    /// Changes selected tab only if it is presented in storage.
    ///
    /// - Parameter tab: The tab object to be selected.
    ///
    /// - Returns: An integer index.
    func select(tab: Tab) -> TabIndex?

    /// Loads tabs data from storage.
    ///
    /// - Returns: A producer with tabs array or error.
    func fetch() -> SignalProducer<[Tab], TabStorageError>

    /// Adds a tab to storage
    ///
    /// - Parameter tab: The tab object to be added.
    func add(tab: Tab)
}

public final class TabsCacheProvider {
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
    public func fetchSelectedIndex() -> SignalProducer<Int, TabStorageError> {
        let producer = SignalProducer<Int, TabStorageError>.init { (observer, _ /* lifetime */) in
            observer.send(value: 0)
            observer.sendCompleted()
        }
        return producer.start(on: scheduler)
    }

    public func select(tab: Tab) -> Int? {
        // TODO: implemente, temporary code
        return nil
    }

    public func fetch() -> SignalProducer<[Tab], TabStorageError> {
        let producer = SignalProducer<[Tab], TabStorageError>.init { (observer, _ /* lifetime */) in
            let tab = Tab(contentType: DefaultTabProvider.shared.contentState, selected: true)
            observer.send(value: [tab])
            observer.sendCompleted()
        }
        return producer.start(on: scheduler)
    }

    public func add(tab: Tab) {
        // TODO: add code
    }
}
