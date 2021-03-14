//
//  TabsDBClient.swift
//  catowser
//
//  Created by Andrei Ermoshin on 9/28/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import CoreData
import CoreBrowser
import HttpKit

enum TabsCoreDataError: Swift.Error {
    case fetchedNothing
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
    
    /// Gets all stored tabs
    func fetchAllTabs() throws -> [Tab] {
        var fetchError: Error?
        var tabs = [Tab]()
        let request: NSFetchRequest<CDTab> = CDTab.fetchRequest()
        managedContext.performAndWait {
            do {
                let result = try managedContext.fetch(request)
                guard !result.isEmpty else {
                    throw TabsCoreDataError.fetchedNothing
                }
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
    
    /// Gets currently selected tab identifier or throws an exception in case of error
    func selectedTabId() throws -> UUID {
        var fetchError: Error?
        var tabIdentifier: UUID?
        let fetchRequest: NSFetchRequest<CDSettings> = CDSettings.fetchRequest()
        fetchRequest.fetchLimit = 1
        managedContext.performAndWait {
            do {
                let result = try managedContext.fetch(fetchRequest)
                guard !result.isEmpty else {
                    throw TabsCoreDataError.fetchedNothing
                }
                guard let cdSettings = result.first else {
                    throw TabsCoreDataError.fetchedTooManyRecords
                }
                guard let actualSelectedTabId = cdSettings.selectedTabId else {
                    throw TabsCoreDataError.selectedTabIdNotPresent
                }
                tabIdentifier = actualSelectedTabId
            } catch {
                fetchError = error
            }
        }
        if let cdError = fetchError {
            throw cdError
        }
        guard let resultId = tabIdentifier else {
            throw TabsCoreDataError.selectedTabIdNotPresent
        }
        return resultId
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
        let fetchRequest: NSFetchRequest<CDSettings> = CDSettings.fetchRequest()
        fetchRequest.fetchLimit = 1
        managedContext.performAndWait {
            do {
                let result = try managedContext.fetch(fetchRequest)
                if result.isEmpty {
                    _ = CDSettings(context: managedContext, selectedTabIdentifier: uuid)
                    try managedContext.save()
                } else {
                    if let existingCdSettings = result.first {
                        existingCdSettings.selectedTabId = uuid
                    } else {
                        _ = CDSettings(context: managedContext, selectedTabIdentifier: uuid)
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
        guard let identifier = cdTab.id else {
            return nil
        }
        guard let createdTime = cdTab.addedTimestamp else {
            return nil
        }
        self.init(contentType: cachedContentType,
                  selected: false,
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
        siteUrl = site.urlInfo.domainURL
    }
}

fileprivate extension CDSettings {
    convenience init(context: NSManagedObjectContext, selectedTabIdentifier: UUID) {
        self.init(context: context)
        self.selectedTabId = selectedTabIdentifier
    }
}
