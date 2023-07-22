//
//  TabsListManager.swift
//  catowser
//
//  Created by Andrei Ermoshin on 28/01/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import Combine

public enum TabsListError: LocalizedError {
    case notInitializedYet
    case selectedNotFound
    case wrongTabContent
    case wrongTabIndexToReplace
}

/**
 Tabs list manager.
 
 Can't really implement this in Singletone pattern due to
 asynс initialization for several parameters during init.
 http://blog.stephencleary.com/2013/01/async-oop-2-constructors.html
 But if we choose some default state for this object we can make async init.
 One empty tab (`.blank` or even tab with favorite sites) will be good default
 state for time before some cached tabs will be fetched from storage.
 
 @Published is used instead of MutableProperty from ReactiveSwift,
 See https://developer.apple.com/documentation/combine/published
 */
public actor TabsListManager {
    /// Current tab selection strategy
    private var selectionStrategy: TabSelectionStrategy

    @Published private var tabs: [Tab] = []
    @Published private var selectedTabId: UUID

    private let storage: TabsStoragable
    private let positioning: TabsStates
    private var observers: [TabsObserver] = [TabsObserver]()

    private var tabsCountCancellable: AnyCancellable?
    private var selectedTabIdCancellable: AnyCancellable?

    public init(storage: TabsStoragable, positioning: TabsStates, selectionStrategy: TabSelectionStrategy) {
        self.selectionStrategy = selectionStrategy
        selectedTabId = positioning.defaultSelectedTabId

        self.storage = storage
        self.positioning = positioning

        // Temporarily delay to wait before first `observer` will be added
        // to send data from storage to it
        let delay = TimeInterval(1)
        
        subscribeForTabsCountChange()
        subscribeForSelectedTabIdChange()
        initTabs(with: delay)
    }

    deinit {
        tabsCountCancellable?.cancel()
        selectedTabIdCancellable?.cancel()
    }
    
    func initTabs(with delay: TimeInterval) {
        Task {
            let delay = UInt64(delay * 1_000_000_000)
            try await Task<Never, Never>.sleep(nanoseconds: delay)
            var cachedTabs = try await storage.fetchAllTabs()
            if cachedTabs.isEmpty {
                let tab = Tab(contentType: await positioning.contentState)
                let savedTab = try await storage.add(tab, select: true)
                cachedTabs = [savedTab]
            }
            let id = try await storage.fetchSelectedTabId()
            guard !cachedTabs.isEmpty else {
                return
            }
            tabs = cachedTabs
            for observer in observers {
                await observer.initializeObserver(with: cachedTabs)
            }
            selectedTabId = id
        }
    }
    
    func subscribeForTabsCountChange() {
        tabsCountCancellable?.cancel()
        tabsCountCancellable = $tabs
            .removeDuplicates { $0.count == $1.count }
            .map { $0.count }
            .sink { tabsCount in
                Task {
                    for observer in self.observers {
                        await observer.update(with: tabsCount)
                    }
                }
            }
    }
    
    func subscribeForSelectedTabIdChange() {
        selectedTabIdCancellable?.cancel()
        selectedTabIdCancellable = $selectedTabId
            .sink(receiveValue: { newSelectedTabId in
                Task { [weak self] in
                    guard let self else {
                        return
                    }
                    guard let tabTuple = await self.tabs.element(by: newSelectedTabId) else {
                        return
                    }
                    for observer in await self.observers {
                        await observer.tabDidSelect(index: tabTuple.index,
                                                    content: tabTuple.tab.contentType,
                                                    identifier: tabTuple.tab.id)
                    }
                }
            })
    }

    /// Returns currently selected tab.
    public func selectedTab() async throws -> Tab {
        guard await selectedId != positioning.defaultSelectedTabId else {
            throw TabsListError.notInitializedYet
        }

        guard let tabTuple = await tabs.element(by: selectedId) else {
            throw TabsListError.selectedNotFound
        }
        return tabTuple.tab
    }
    
    /// Returns index of selected tab
    public func selectedIndex() async throws -> Int {
        guard let tabTuple = await tabs.element(by: selectedId) else {
            throw TabsListError.notInitializedYet
        }
        return tabTuple.index
    }
    
    /// Replaces tab at specific index
    public func replaceInMemory(_ tab: Tab, _ index: Int) throws {
        guard index >= 0 && index < tabs.count else {
            throw TabsListError.wrongTabIndexToReplace
        }
        tabs[index] = tab
    }
}

extension TabsListManager: IndexSelectionContext {
    public var collectionLastIndex: Int {
        get async {
            // -1 index is not possible because always should be at least 1 tab
            let amount = tabs.count
            // Leaving assert even with unit tests
            // https://stackoverflow.com/a/410198
            assert(amount != 0, "Tabs amount shouldn't be 0")
            return amount - 1
        }
    }

    public var currentlySelectedIndex: Int {
        get async {
            // Leaving assert even with unit tests
            // https://stackoverflow.com/a/410198
            assert(!tabs.isEmpty, "Tabs amount shouldn't be 0")
            if let tabTuple = await tabs.element(by: selectedId) {
                return tabTuple.index
            }
            // tabs collection shouldn't be empty, so,
            // it is safe to return index of 1st element
            return 0
        }
    }
}

extension TabsListManager: TabsSubject {
    public func fetch() async -> [Tab] {
        tabs
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
            let tab: Tab = .init(contentType: contentState)
            _ = try await storage.add(tab, select: true)
        } catch {
            // tab view should be removed immediately on view level anyway
            print("Failure to remove tab and reset to one tab: \(error)")
        }
    }

    public func add(tab: Tab) async {
        let positionType = await positioning.addPosition
        let pair = positionType.addTab(tab, to: tabs, currentlySelectedId: selectedTabId)
        let newIndex = pair.0
        tabs = pair.1
        let needSelect = selectionStrategy.makeTabActiveAfterAdding
        do {
            let addedTab = try await storage.add(tab, select: needSelect)
            await handleTabAdded(addedTab, index: newIndex, select: needSelect)
        } catch {
            // It doesn't matter, on view level it must be added right away
            print("Failed to add this tab to cache: \(error)")
        }
    }

    public func select(tab: Tab) async {
        do {
            let identifier = try await storage.select(tab: tab)
            guard identifier != selectedTabId else {
                return
            }
            self.selectedTabId = identifier
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
            // Need to notify observers to allow them
            // to update title for tab view
            for observer in observers {
                await observer.tabDidReplace(newTab, at: tabIndex)
            }
        } catch {
            print("Failed to update tab content to storage \(error)")
        }
    }

    public func attach(_ observer: TabsObserver, notify: Bool = false) async {
        observers.append(observer)
        guard notify && selectedTabId != positioning.defaultSelectedTabId else {
            return
        }
        guard let tabTuple = await tabs.element(by: selectedId) else {
            return
        }
        await observer.tabDidSelect(index: tabTuple.index,
                                    content: tabTuple.tab.contentType,
                                    identifier: tabTuple.tab.id)
    }

    public func detach(_ observer: TabsObserver) async {
        let name = await observer.name
        for iterator in observers.enumerated() where await iterator.element.name == name {
            observers.remove(at: iterator.offset)
            break
        }
    }
    
    public var tabsCount: Int {
        get async {
            tabs.count
        }
    }
    
    public var selectedId: UUID {
        get async {
            selectedTabId
        }
    }
}

private extension TabsListManager {
    func handleTabAdded(_ tab: Tab, index: Int, select: Bool) async {
        // can select new tab only after adding it
        // this is because corresponding view should be in the list
        
        switch positioning.addSpeed {
        case .immediately:
            for observer in observers {
                await observer.tabDidAdd(tab, at: index)
            }
            if select {
                selectedTabId = tab.id
            }
        case .after(let interval):
            if #available(iOS 16, *) {
                do {
                    try await Task.sleep(for: interval.dispatchValue)
                    for observer in observers {
                        await observer.tabDidAdd(tab, at: index)
                    }
                    if select {
                        selectedTabId = tab.id
                    }
                } catch {
                    print("Failed to wait before adding a new tab: \(error)")
                }
            } else {
                // TODO: implement postponed adding of a tab when before iOS 16
                for observer in observers {
                    await observer.tabDidAdd(tab, at: index)
                }
                if select {
                    selectedTabId = tab.id
                }
            }
        }
    }
    
    func handleCachedTabRemove(_ tab: Tab) async {
        // if it is a last tab - replace it with a tab with default content
        // browser can't function without at least one tab
        // so, this is kind of a side effect of removing the only one last tab
        if tabs.count == 1 {
            tabs.removeAll()
            Task {
                let contentState = await positioning.contentState
                let tab: Tab = .init(contentType: contentState)
                await add(tab: tab)
            }
        } else {
            guard let closedTabIndex = tabs.firstIndex(of: tab) else {
                fatalError("Closing non existing tab")
            }

            let newIndex = await selectionStrategy.autoSelectedIndexAfterTabRemove(self, removedIndex: closedTabIndex)
            // need to remove it before changing selected index
            // otherwise in one case the handler will select closed tab
            tabs.remove(at: closedTabIndex)
            
            guard let selectedTab = tabs[safe: newIndex] else {
                fatalError("Failed to find new selected tab")
            }
            selectedTabId = selectedTab.id
        }
    }
}

fileprivate extension Array where Element == Tab {
    func element(by uuid: UUID) -> (tab: Tab, index: Int)? {
        for (ix, tab) in self.enumerated() where tab.id == uuid {
            return (tab, ix)
        }
        return nil
    }
}

extension AddedTabPosition {
    func addTab(_ tab: Tab,
                to currentTabs: [Tab],
                currentlySelectedId: UUID) -> (Int, [Tab]) {
        var tabs = currentTabs
        let newIndex: Int
        switch self {
        case .listEnd:
            tabs.append(tab)
            newIndex = tabs.count - 1
        case .afterSelected:
            guard let tabTuple = tabs.element(by: currentlySelectedId) else {
                // no previously selected tab, probably when reset to one tab happend
                tabs.append(tab)
                return (tabs.count - 1, tabs)
            }
            newIndex = tabTuple.index + 1
            tabs.insert(tab, at: newIndex)
        }
        
        return (newIndex, tabs)
    }
}
