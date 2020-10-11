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

enum TabResourceError: Error {
    case zombieSelf
    case storeNotInitializedYet
    case dummyError
    case insertError(Error)
    case deleteError(Error)
    case fetchAllError(Error)
}

fileprivate extension String {
    static let threadName = "tabsStore"
}

final class TabsResource {
    private var store: TabsStore
    
    /// Needs to be checked on every access to `store` to not use wrong context
    /// functions can return empty data if it's not initialized state
    private var isStoreInitialized = false
    
    private let queue: DispatchQueue = .init(label: .queueNameWith(suffix: .threadName))
    
    private lazy var scheduler: QueueScheduler = .init(qos: .background, name: .threadName, targeting: queue)
    
    init() {
        // Creating temporary instance to be able to use background thread
        // to properly create private CoreData context
        let dummyStore: TabsStore = .init(TabsEnvironment.shared.cottonDb.viewContext)
        store = dummyStore
        queue.sync { [weak self] in
            let privateContext = TabsEnvironment.shared.cottonDb.newPrivateContext()
            guard let self = self else {
                return
            }
            self.store = .init(privateContext)
            self.isStoreInitialized = true
        }
    }
    
    func remember(tab: Tab) -> SignalProducer<Void, TabResourceError> {
        let producer: SignalProducer<Void, TabResourceError> = .init { [weak self] (observer, lifetime) in
            guard let self = self else {
                observer.send(error: .zombieSelf)
                return
            }
            guard self.isStoreInitialized else {
                observer.send(error: .storeNotInitializedYet)
                return
            }
            
            do {
                try self.store.insert(tab: tab)
                observer.send(value: ())
                observer.sendCompleted()
            } catch {
                observer.send(error: .insertError(error))
            }
            
        }
        
        return producer.observe(on: scheduler)
    }
    
    func forget(tab: Tab) -> SignalProducer<Void, TabResourceError> {
        let producer: SignalProducer<Void, TabResourceError> = .init { [weak self] (observer, lifetime) in
            guard let self = self else {
                observer.send(error: .zombieSelf)
                return
            }
            guard self.isStoreInitialized else {
                observer.send(error: .storeNotInitializedYet)
                return
            }
            
            do {
                try self.store.remove(tab: tab)
                observer.send(value: ())
                observer.sendCompleted()
            } catch {
                observer.send(error: .deleteError(error))
            }
            
        }
        return producer.observe(on: scheduler)
    }
    
    func tabsFromLastSession() -> SignalProducer<[Tab], TabResourceError> {
        let producer: SignalProducer<[Tab], TabResourceError> = .init { [weak self] (observer, lifetime) in
            guard let self = self else {
                observer.send(error: .zombieSelf)
                return
            }
            guard self.isStoreInitialized else {
                observer.send(error: .storeNotInitializedYet)
                return
            }
            
            do {
                let tabs = try self.store.fetchAllTabs()
                observer.send(value: tabs)
                observer.sendCompleted()
            } catch {
                observer.send(error: .fetchAllError(error))
            }
            
        }
        return producer.observe(on: scheduler)
    }
}
