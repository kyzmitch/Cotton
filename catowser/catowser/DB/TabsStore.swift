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
        var fetchError: Error?
        var tabs = [Tab]()
        managedContext.performAndWait {
            let request: NSFetchRequest<CDTab> = CDTab.fetchRequest()
            do {
                let result = try managedContext.fetch(request)
                tabs = result.compactMap {Tab(cdTab: $0)}
            } catch {
                fetchError = error
            }
        }
        if let cdError = fetchError {
            throw cdError
        }
        return tabs
    }
    
    /// Should be only one tab record which has selected state
    func selectedTabIndex() throws -> UInt {
        return 0
    }
}

fileprivate extension Site.Settings {
    init(cdSettings: CDSiteSettings) {
        self.init(popupsBlock: cdSettings.blockPopups,
                  javaScriptEnabled: cdSettings.canLoadPlugins,
                  privateTab: cdSettings.isPrivate)
        self.isJsEnabled = cdSettings.isJsEnabled
    }
}

fileprivate extension Site {
    init?(cdSite: CDSite) {
        guard let url = cdSite.siteUrl else {
            return nil
        }
        guard let cdSettings = cdSite.settings else {
            return nil
        }
        let settings = Site.Settings(cdSettings: cdSettings)
        self.init(url: url, searchSuggestion: cdSite.searchSuggestion, settings: settings)
        highQualityFaviconImage = nil
    }
}

fileprivate extension Tab {
    init?(cdTab: CDTab) {
        let cachedSite: Site?
        if let cdSite = cdTab.site {
            cachedSite = Site(cdSite: cdSite)
        } else {
            cachedSite = nil
        }
        
        guard let cachedContentType = Tab.ContentType.create(rawValue: cdTab.contentType, site: cachedSite) else {
            return nil
        }
        guard let visualState = Tab.VisualState(rawValue: cdTab.visualState) else {
            return nil
        }
        self.init(contentType: cachedContentType, selected: visualState == .selected, idenifier: cdTab.id)
        
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
        siteUrl = site.urlInfo.domainURL
    }
}
