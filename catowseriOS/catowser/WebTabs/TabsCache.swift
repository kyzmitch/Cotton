//
//  TabsCache.swift
//  catowser
//
//  Created by Andrei Ermoshin on 28/01/2019.
//  Copyright © 2019 Cotton (former Catowser). All rights reserved.
//

import Foundation
import CoreBrowser
import CoreData

/**
 Declaring Tab storage type in host app instead of `CoreBrowser`
 to allow use app settings like default tab content which only can be stored in host app,
 because it can't be passed as an argument to Tabs manager since it is a singleton.
 Anyway, now it's not a singletone, since we're passing tabs store instance to it, but
 with environment class which holds reference to tabs list manager it's kind of singletone.
 */
final class TabsCacheProvider {
    private let tabsDbResource: TabsResource

    init(_ temporaryContext: NSManagedObjectContext,
         _ privateContextCreator: @escaping () -> NSManagedObjectContext?) {
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

    func update(tab: Tab) throws -> Tab {
        do {
            return try tabsDbResource.update(tab: tab)
        } catch {
            throw TabStorageError.dbResourceError(error)
        }
    }

    func remove(tabs: [Tab]) async throws -> [Tab] {
        do {
            return try await tabsDbResource.forget(tabs: tabs)
        } catch {
            throw TabStorageError.dbResourceError(error)
        }
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
