//
//  WriteTabsUseCaseImpl.swift
//  CoreBrowser
//
//  Created by Andrey Ermoshin on 04.01.2024.
//  Copyright © 2024 andreiermoshin. All rights reserved.
//

import Foundation

public final class WriteTabsUseCaseImpl: WriteTabsUseCase {
    private let tabsDataService: TabsDataService
    
    public init(_ tabsDataService: TabsDataService) {
        self.tabsDataService = tabsDataService
    }
    
    public func add(tab: Tab) async {
        let positionType = await positioning.addPosition
        let pair = positionType.addTab(tab, to: tabs, selectedTabIdentifier)
        let newIndex = pair.0
        tabs = pair.1
        tabsCountInput.yield(tabs.count)
        let needSelect = selectionStrategy.makeTabActiveAfterAdding
        do {
            let addedTab = try await storage.add(tab, select: needSelect)
            await handleTabAdded(addedTab, index: newIndex, select: needSelect)
        } catch {
            // It doesn't matter, on view level it must be added right away
            print("Failed to add this tab to cache: \(error)")
        }
    }
    
    public func close(tab: Tab) async {
        do {
            let removedTabs = try await storage.remove(tabs: [tab])
            // swiftlint:disable:next force_unwrapping
            await handleCachedTabRemove(removedTabs.first!)
        } catch {
            // tab view should be removed immediately on view level anyway
            print("Failure to remove tab from cache: \(error)")
        }
    }
    
    public func closeAll() async {
        let contentState = await positioning.contentState
        do {
            _ = try await storage.remove(tabs: tabs)
            tabs.removeAll()
            tabsCountInput.yield(0)
            let tab: Tab = .init(contentType: contentState)
            _ = try await storage.add(tab, select: true)
        } catch {
            // tab view should be removed immediately on view level anyway
            print("Failure to remove tab and reset to one tab: \(error)")
        }
    }
    
    public func select(tab: Tab) async {
        do {
            let identifier = try await storage.select(tab: tab)
            guard identifier != selectedTabIdentifier else {
                return
            }
            selectedTabIdentifier = identifier
            selectedTabIdInput.yield(identifier)
        } catch {
            print("Failed to select tab with id \(tab.id) \(error)")
        }
    }
    
    public func replaceSelected(_ tabContent: Tab.ContentType) async throws {
        guard let tabTuple = await tabs.element(by: selectedId) else {
            throw TabsListError.notInitializedYet
        }
        guard tabTuple.tab.contentType != tabContent else {
            return
        }
        var newTab = tabTuple.tab
        let tabIndex = tabTuple.index
        newTab.contentType = tabContent
        newTab.previewData = nil
        
        do {
            _ = try storage.update(tab: newTab)
            tabs[tabIndex] = newTab
            // Need to notify observers to allow them to update title for tab view
            for observer in tabObservers {
                await observer.tabDidReplace(newTab, at: tabIndex)
            }
        } catch {
            print("Failed to update tab content to storage \(error)")
        }
    }
}
