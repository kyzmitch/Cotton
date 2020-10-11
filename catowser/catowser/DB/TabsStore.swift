//
//  TabsStore.swift
//  catowser
//
//  Created by Andrei Ermoshin on 9/28/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import CoreData
import CoreBrowser

final class TabsStore {
    private let managedContext: NSManagedObjectContext
    
    init(_ managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
    }
    
    func insert(tab: Tab) throws {
        managedContext.performAndWait {
            
        }
    }
    
    func remove(tab: Tab) throws {
        
    }
    
    func fetchAllTabs() throws -> [Tab] {
        return []
    }
    
    /// Should be only one tab record which has selected state
    func selectedTabIndex() throws -> UInt {
        return 0
    }
}
