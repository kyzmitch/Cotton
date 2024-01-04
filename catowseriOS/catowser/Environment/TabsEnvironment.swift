//
//  TabsEnvironment.swift
//  catowser
//
//  Created by Andrei Ermoshin on 5/28/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import CoreBrowser
import CoreData

private final class TabsEnvironment {
    static func shared() async -> ManagerHolder {
        if let holder = internalHolder {
            return holder
        }
        
        let created = await ManagerHolder()
        internalHolder = created
        return created
    }
    
    static private var internalHolder: ManagerHolder?
    
    fileprivate actor ManagerHolder {
        let cachedTabsManager: TabsDataService
        private let database: Database
        
        init() async {
            guard let database = Database(name: "CottonDbModel") else {
                fatalError("Failed to initialize CoreData database")
            }
            do {
                try await database.loadStore()
            } catch {
                fatalError("Failed to initialize Database \(error.localizedDescription)")
            }
            self.database = database
            let contextClosure = { [weak database] () -> NSManagedObjectContext? in
                guard let dbInterface = database else {
                    fatalError("Cotton db reference is nil")
                }
                return dbInterface.newPrivateContext()
            }
            let cacheProvider = TabsCacheProvider(database.viewContext, contextClosure)
            let strategy = NearbySelectionStrategy()
            cachedTabsManager = await .init(cacheProvider, DefaultTabProvider.shared, strategy)
        }
    }
}

extension TabsDataService {
    static var shared: TabsDataService {
        get async {
            await TabsEnvironment.shared().cachedTabsManager
        }
    }
}
