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
    case dummyError
    case insertError(Error)
}

final class TabsResource {
    private var store: TabsStore
    
    /// Needs to be checked on every access to `store` to not use wrong context
    /// functions can return empty data if it's not initialized state
    private var isStoreInitialized = false
    
    private let queue: DispatchQueue = .init(label: .queueNameWith(suffix: "tabsStore"))
    
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
        // TODO: use queue or scheduler and store
        .init(error: .dummyError)
    }
    
    func forget(tab: Tab) -> SignalProducer<Void, TabResourceError> {
        // TODO: use queue or scheduler and store
        .init(error: .dummyError)
    }
    
    func loadAllTabs() -> SignalProducer<[Tab], TabResourceError> {
        // TODO: use queue or scheduler and store
        .init(value: [])
    }
}
