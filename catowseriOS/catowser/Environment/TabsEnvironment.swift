//
//  TabsEnvironment.swift
//  catowser
//
//  Created by Andrei Ermoshin on 5/28/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import CoreBrowser
import CoreData

@globalActor
private final class TabsEnvironment {
    static let shared: ManagerHolder = .init()
    
    fileprivate actor ManagerHolder {
        let cachedTabsManager: TabsListManager
        let cottonDb: Database
        
        init() {
            guard let database = Database(name: "CottonDbModel") else {
                fatalError("Failed to initialize CoreData database")
            }
            database.loadStore { (loadingError) in
                guard let dbLoadingError = loadingError else {
                    return
                }
                fatalError("Failed to initialize Database \(dbLoadingError.localizedDescription)")
            }
            cottonDb = database
            let contextClosure = { [weak cottonDb] () -> NSManagedObjectContext? in
                guard let dbInterface = cottonDb else {
                    fatalError("Cotton db reference is nil")
                }
                return dbInterface.newPrivateContext()
            }
            let tabsCacheProvider: TabsCacheProvider = .init(temporaryContext: cottonDb.viewContext,
                                                             privateContextCreator: contextClosure)
            cachedTabsManager = .init(storage: tabsCacheProvider,
                                      positioning: DefaultTabProvider.shared,
                                      selectionStrategy: NearbySelectionStrategy())
        }
    }
}

extension TabsListManager {
    static var shared: TabsListManager {
        return TabsEnvironment.shared.cachedTabsManager
    }
}
