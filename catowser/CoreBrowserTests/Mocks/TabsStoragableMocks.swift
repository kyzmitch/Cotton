//
//  TabsStoragableMocks.swift
//  CoreBrowserTests
//
//  Created by Andrei Ermoshin on 10/9/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CoreBrowser
import ReactiveSwift

final class MockedWithErrorTabsStorage: TabsStoragable {
    init() {}
    
    func fetchSelectedTabId() -> SignalProducer<UUID, TabStorageError> {
        let producer: SignalProducer<UUID, TabStorageError> = .init { (observer, _) in
            observer.send(error: .notImplemented)
        }
        return producer
    }
    
    func select(tab: Tab) -> SignalProducer<UUID, TabStorageError> {
        let producer: SignalProducer<UUID, TabStorageError> = .init { (observer, _) in
            observer.send(error: .notImplemented)
        }
        return producer
    }
    
    func fetchAllTabs() -> SignalProducer<[Tab], TabStorageError> {
        let producer: SignalProducer<[Tab], TabStorageError> = .init { (observer, _) in
            observer.send(error: .notImplemented)
        }
        return producer
    }
    
    func add(tab: Tab, andSelect select: Bool) -> SignalProducer<Tab, TabStorageError> {
        let producer: SignalProducer<Tab, TabStorageError> = .init { (observer, _) in
            observer.send(error: .notImplemented)
        }
        return producer
    }
    
    func update(tab: Tab) -> SignalProducer<Tab, TabStorageError> {
        let producer: SignalProducer<Tab, TabStorageError> = .init { (observer, _) in
            observer.send(error: .notImplemented)
        }
        return producer
    }
    
    func remove(tab: Tab) -> SignalProducer<Tab, TabStorageError> {
        let producer: SignalProducer<Tab, TabStorageError> = .init { (observer, _) in
            observer.send(error: .notImplemented)
        }
        return producer
    }
    
    func remove(tabs: [Tab]) -> SignalProducer<[Tab], TabStorageError> {
        let producer: SignalProducer<[Tab], TabStorageError> = .init { (observer, _) in
            observer.send(error: .notImplemented)
        }
        return producer
    }
}

final class MockedGoodErrorTabsStorage: TabsStoragable {
    private var selectedUUID: UUID
    private var tabs: [Tab]
    
    init(selected: UUID, tabs: [Tab]) {
        selectedUUID = selected
        self.tabs = tabs
    }
    
    func fetchSelectedTabId() -> SignalProducer<UUID, TabStorageError> {
        let producer: SignalProducer<UUID, TabStorageError> = .init { (observer, _) in
            observer.send(value: self.selectedUUID)
        }
        return producer
    }
    
    func select(tab: Tab) -> SignalProducer<UUID, TabStorageError> {
        let producer: SignalProducer<UUID, TabStorageError> = .init { (observer, _) in
            observer.send(value: tab.id)
        }
        return producer
    }
    
    func fetchAllTabs() -> SignalProducer<[Tab], TabStorageError> {
        let producer: SignalProducer<[Tab], TabStorageError> = .init { (observer, _) in
            observer.send(value: self.tabs)
        }
        return producer
    }
    
    func add(tab: Tab, andSelect select: Bool) -> SignalProducer<Tab, TabStorageError> {
        let producer: SignalProducer<Tab, TabStorageError> = .init { (observer, _) in
            observer.send(value: tab)
        }
        return producer
    }
    
    func update(tab: Tab) -> SignalProducer<Tab, TabStorageError> {
        let producer: SignalProducer<Tab, TabStorageError> = .init { (observer, _) in
            observer.send(value: tab)
        }
        return producer
    }
    
    func remove(tab: Tab) -> SignalProducer<Tab, TabStorageError> {
        let producer: SignalProducer<Tab, TabStorageError> = .init { (observer, _) in
            observer.send(value: tab)
        }
        return producer
    }
    
    func remove(tabs: [Tab]) -> SignalProducer<[Tab], TabStorageError> {
        let producer: SignalProducer<[Tab], TabStorageError> = .init { (observer, _) in
            observer.send(value: tabs)
        }
        return producer
    }
}
