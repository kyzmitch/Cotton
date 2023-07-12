//
//  TabsDBClient.swift
//  catowser
//
//  Created by Andrei Ermoshin on 9/28/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import CoreData
import CoreBrowser
import CottonBase

enum TabsCoreDataError: Swift.Error {
    case mgContextNil
    case noAppSettingsRecordWasFound
    case fetchedTooManyRecords
    case selectedTabIdNotPresent
}

final class TabsDBClient {
    private let managedContext: NSManagedObjectContext
    
    init(_ managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
    }
    
    /// Adds the tab without selecting it
    func insert(tab: Tab) throws {
        var saveError: Error?
        managedContext.performAndWait {
            _ = CDTab(context: managedContext, tab: tab)
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
    
    /// Updates existing tab record with new content.
    /// E.g. when it was topSites and now it is actual web site
    func update(tab: Tab) throws {
        var saveError: Error?
        let fetchRequest: NSFetchRequest<CDTab> = CDTab.fetchRequest()
        let query = NSPredicate(format: "%K = %@", "id", tab.id as CVarArg)
        fetchRequest.predicate = query
        
        managedContext.performAndWait {
            do {
                let result = try managedContext.fetch(fetchRequest)
                if !result.isEmpty, let cdTab = result.first {
                    cdTab.contentType = tab.contentType.rawValue
                    if let oldCdSite = cdTab.site {
                        managedContext.delete(oldCdSite)
                    }
                    if let newSite = tab.site {
                        let cdSite = CDSite(context: managedContext, site: newSite)
                        cdSite.tab = cdTab
                        cdTab.site = cdSite
                    }
                } else {
                    _ = CDTab(context: managedContext, tab: tab)
                }
                try managedContext.save()
            } catch {
                saveError = error
            }
        }
        if let actualError = saveError {
            throw actualError
        }
    }
    
    /// Removes the tab, if it was selected it doesn't do de-selection logic
    /// De-selection should happen on application side because different auto-selection
    /// strategies could be used and it shouldn't be performed as a side-effect
    func remove(tab: Tab) throws {
        var cdError: Error?
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CDTab.fetchRequest()
        let query = NSPredicate(format: "%K = %@", "id", tab.id as CVarArg)
        fetchRequest.predicate = query
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        managedContext.performAndWait {
            do {
                try managedContext.execute(batchDeleteRequest)
            } catch {
                cdError = error
            }
        }
        if let actualError = cdError {
            throw actualError
        }
    }
    
    /// Removes all the records of tabs
    func removeAll(tabs: [Tab]) throws {
        var cdError: Error?
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CDTab.fetchRequest()
        let query = NSPredicate(format: "id = %@", argumentArray: tabs.map {$0.id})
        fetchRequest.predicate = query
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        managedContext.performAndWait {
            do {
                try managedContext.execute(batchDeleteRequest)
            } catch {
                cdError = error
            }
        }
        if let actualError = cdError {
            throw actualError
        }
    }
    
    /// Updates selected tab identifier using it from the `tab` provided as a argument
    func select(tab: Tab) throws {
        try setSelectedTab(uuid: tab.id)
    }
    
    /// Updates selected tab identifier using `uuid` argument
    func setSelectedTab(uuid: UUID) throws {
        var setError: Error?
        
        managedContext.performAndWait {
            do {
                try setSettingsSelectedTabId(uuid)
            } catch {
                setError = error
            }
        }
        if let cdError = setError {
            throw cdError
        }
    }
    
    /// Updates existing db record or creates a brand new one for selected tab identifier
    private func setSettingsSelectedTabId(_ uuid: UUID) throws {
        var fetchError: Error?
        let fetchRequest: NSFetchRequest<CDAppSettings> = CDAppSettings.fetchRequest()
        fetchRequest.fetchLimit = 1
        managedContext.performAndWait {
            do {
                let result = try managedContext.fetch(fetchRequest)
                if result.isEmpty {
                    _ = CDAppSettings(context: managedContext, selectedTabIdentifier: uuid)
                    try managedContext.save()
                } else {
                    if let existingCdSettings = result.first {
                        existingCdSettings.selectedTabId = uuid
                    } else {
                        _ = CDAppSettings(context: managedContext, selectedTabIdentifier: uuid)
                    }
                    try managedContext.save()
                }
            } catch {
                fetchError = error
            }
        }
        
        if let cdError = fetchError {
            throw cdError
        }
    }
}

fileprivate extension Site.Settings {
    convenience init(cdSettings: CDSiteSettings) {
        self.init(isPrivate: cdSettings.isPrivate,
                  blockPopups: cdSettings.blockPopups,
                  isJSEnabled: cdSettings.canLoadPlugins,
                  canLoadPlugins: cdSettings.canLoadPlugins)
    }
}

fileprivate extension Site {
    convenience init?(cdSite: CDSite) {
        guard let url = cdSite.siteUrl else {
            return nil
        }
        guard let cdSettings = cdSite.settings else {
            return nil
        }
        guard let urlInfo = URLInfo(url) else {
            return nil
        }
        let settings = Site.Settings(cdSettings: cdSettings)
        self.init(urlInfo: urlInfo,
                  settings: settings,
                  faviconData: nil,
                  searchSuggestion: cdSite.searchSuggestion,
                  userSpecifiedTitle: nil)
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
        guard let identifier = cdTab.id else {
            return nil
        }
        guard let createdTime = cdTab.addedTimestamp else {
            return nil
        }
        self.init(contentType: cachedContentType,
                  idenifier: identifier,
                  created: createdTime)
        
    }
}

fileprivate extension CDTab {
    convenience init(context: NSManagedObjectContext, tab: Tab) {
        self.init(context: context)
        id = tab.id
        contentType = tab.contentType.rawValue
        addedTimestamp = tab.addedTimestamp
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
        siteUrl = site.urlInfo.platformURL
        settings = CDSiteSettings(context: context, siteSettings: site.settings)
    }
}

fileprivate extension CDSiteSettings {
    convenience init(context: NSManagedObjectContext, siteSettings: Site.Settings) {
        self.init(context: context)
        blockPopups = siteSettings.blockPopups
        canLoadPlugins = siteSettings.canLoadPlugins
        isJsEnabled = siteSettings.isJSEnabled
        isPrivate = siteSettings.isPrivate
    }
}

fileprivate extension CDAppSettings {
    convenience init(context: NSManagedObjectContext, selectedTabIdentifier: UUID) {
        self.init(context: context)
        self.selectedTabId = selectedTabIdentifier
    }
}

extension TabsDBClient {
    /// Gets all stored tabs
    func fetchAllTabs() async throws -> [Tab] {
        return try await managedContext.perform {
            let request: NSFetchRequest<CDTab> = CDTab.fetchRequest()
            let result = try request.execute()
            return result.compactMap {Tab(cdTab: $0)}
        }
    }
    
    func insert(tab: Tab) async throws {
        return try await managedContext.perform { [weak managedContext] in
            guard let managedContext else {
                return
            }
            _ = CDTab(context: managedContext, tab: tab)
            try managedContext.save()
        }
    }
    
    func select(tab: Tab) async throws {
        try await setSettingsSelectedTabId(tab.id)
    }
    
    private func setSettingsSelectedTabId(_ uuid: UUID) async throws {
        return try await managedContext.perform { [weak managedContext] in
            guard let managedContext else {
                return
            }
            let fetchRequest: NSFetchRequest<CDAppSettings> = CDAppSettings.fetchRequest()
            fetchRequest.fetchLimit = 1
            let result = try managedContext.fetch(fetchRequest)
            if result.isEmpty {
                _ = CDAppSettings(context: managedContext, selectedTabIdentifier: uuid)
                try managedContext.save()
            } else {
                if let existingCdSettings = result.first {
                    existingCdSettings.selectedTabId = uuid
                } else {
                    _ = CDAppSettings(context: managedContext, selectedTabIdentifier: uuid)
                }
                try managedContext.save()
            }
        }
    }
    
    func selectedTabId() async throws -> UUID {
        return try await managedContext.perform { [weak managedContext] in
            guard let managedContext else {
                throw TabsCoreDataError.mgContextNil
            }
            
            let fetchRequest: NSFetchRequest<CDAppSettings> = CDAppSettings.fetchRequest()
            fetchRequest.fetchLimit = 1
            
            let result = try managedContext.fetch(fetchRequest)
            guard !result.isEmpty else {
                throw TabsCoreDataError.noAppSettingsRecordWasFound
            }
            guard let cdSettings = result.first else {
                throw TabsCoreDataError.fetchedTooManyRecords
            }
            guard let actualSelectedTabId = cdSettings.selectedTabId else {
                throw TabsCoreDataError.selectedTabIdNotPresent
            }
            return actualSelectedTabId
        }
    }
}
