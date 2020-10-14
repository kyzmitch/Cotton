//
//  TabsStore.swift
//  catowser
//
//  Created by Andrei Ermoshin on 9/28/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import CoreData
import CoreBrowser
import HttpKit

final class TabsStore {
    private let managedContext: NSManagedObjectContext
    
    init(_ managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
    }
    
    func insert(tab: Tab) throws {
        var saveError: Error?
        managedContext.performAndWait {
            _ = CDTab(context: managedContext)
            do {
                try managedContext.save()
            } catch {
                saveError = error
            }
        }
        if let actualError = saveError {
            throw actualError
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

fileprivate extension CDTab {
    convenience init(context: NSManagedObjectContext, tab: Tab) {
        self.init(context: context)
        id = tab.id
        contentType = tab.contentType.rawValue
        visualState = tab.visualState.rawValue
        if case .site(let siteContent) = tab.contentType {
            site = CDSite(context: context, site: siteContent)
        }
    }
}

fileprivate extension CDSite {
    convenience init(context: NSManagedObjectContext, site: Site) {
        self.init(context: context)
        searchSuggestion = site.searchSuggestion
        userSpecifiedTitle = site.userSpecifiedTitle
        urlInfo = CDURLIpInfo(context: context, urlInfo: site.urlInfo)
    }
}

fileprivate extension CDURLIpInfo {
    convenience init(context: NSManagedObjectContext, urlInfo: HttpKit.URLIpInfo) {
        self.init(context: context)
        internalUrl = urlInfo.domainURL
        ipAddress = urlInfo.ipAddress
    }
}
