//
//  TabsListManager.swift
//  catowser
//
//  Created by Andrei Ermoshin on 28/01/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

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
 
 https://forums.swift.org/t/how-do-you-use-asyncstream-to-make-task-execution-deterministic/57968/2
 */
public actor TabsDataService {
    typealias UUIDStream = AsyncStream<UUID>
    typealias IntStream = AsyncStream<Int>
    
    /// Tabs selection strategy
    private let selectionStrategy: TabSelectionStrategy
    /// In memory storage for the tabs
    private var tabs: [Tab] = []
    /// Async stream for the selected tab id instead of using Combine's @Published
    private var selectedTabIdStream: UUIDStream!
    /// Async's stream continuation to notify about new id
    private var selectedTabIdInput: UUIDStream.Continuation!
    ///  Simple variable needed for direct sync access and for async getter
    private var selectedTabIdentifier: UUID
    /// Tabs count stream
    private var tabsCountStream: IntStream!
    /// Tabs count input for the async stream
    private var tabsCountInput: IntStream.Continuation!

    private let storage: TabsStoragable
    private let positioning: TabsStates
    private var tabObservers: [TabsObserver]

    public init(_ storage: TabsStoragable,
                _ positioning: TabsStates,
                _ selectionStrategy: TabSelectionStrategy) async {
        self.selectionStrategy = selectionStrategy
        self.storage = storage
        self.positioning = positioning
        self.tabObservers = []
        self.selectedTabIdentifier = positioning.defaultSelectedTabId
        
#if swift(>=5.9)
        let (tabIdStream, tabIdContinuation) = AsyncStream.makeStream(of: UUID.self)
        selectedTabIdStream = tabIdStream
        selectedTabIdInput = tabIdContinuation
        tabIdContinuation.yield(positioning.defaultSelectedTabId)
        let (countStream, countContinuation) = AsyncStream.makeStream(of: Int.self)
        tabsCountStream = countStream
        tabsCountInput = countContinuation
#else
        self.selectedTabIdStream = UUIDStream { continuation in
            // A hack to be able to send values outside of the closure
            selectedTabIdInput = continuation
            continuation.yield(positioning.defaultSelectedTabId)
        }
        self.tabsCountStream = IntStream { continuation in
            tabsCountInput = continuation
        }
#endif
        
        subscribeForTabsCountChange()
        subscribeForSelectedTabIdChange()
        do {
            try await fetchTabs()
        } catch {
            if ProcessInfo.unitTesting {
                print("Failed to init tabs manager: \(error)")
            } else {
                fatalError("Fail to init tabs")
            }
        }
    }
    
    /// Replaces tab at specific index
    public func replaceInMemory(_ tab: Tab, _ index: Int) throws {
        guard index >= 0 && index < tabs.count else {
            throw TabsListError.wrongTabIndexToReplace
        }
        tabs[index] = tab
    }
}

extension TabsDataService: IndexSelectionContext {
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

extension TabsDataService: TabsSubject {
    public func attach(_ observer: TabsObserver, notify: Bool = false) async {
        tabObservers.append(observer)
        guard notify else {
            return
        }
        await observer.updateTabsCount(with: tabs.count)
        await observer.initializeObserver(with: tabs)
        guard selectedTabIdentifier != positioning.defaultSelectedTabId else {
            return
        }
        guard let tabTuple = await tabs.element(by: selectedId) else {
            return
        }
        await observer.tabDidSelect(tabTuple.index, tabTuple.tab.contentType, tabTuple.tab.id)
    }

    public func detach(_ observer: TabsObserver) async {
        let name = await observer.tabsObserverName
        for iterator in tabObservers.enumerated() where await iterator.element.tabsObserverName == name {
            tabObservers.remove(at: iterator.offset)
            break
        }
    }
}

private extension TabsDataService {
    func handleTabAdded(_ tab: Tab, index: Int, select: Bool) async {
        // can select new tab only after adding it
        // this is because corresponding view should be in the list
        
        switch positioning.addSpeed {
        case .immediately:
            for observer in tabObservers {
                await observer.tabDidAdd(tab, at: index)
            }
            if select {
                selectedTabIdentifier = tab.id
                selectedTabIdInput.yield(tab.id)
            }
        case .after(let interval):
            do {
                if #available(iOS 16, *) {
                    try await Task.sleep(for: interval.dispatchValue)
                    
                } else {
                    try await Task.sleep(nanoseconds: interval.inNanoseconds)
                }
                for observer in tabObservers {
                    await observer.tabDidAdd(tab, at: index)
                }
                if select {
                    selectedTabIdentifier = tab.id
                    selectedTabIdInput.yield(tab.id)
                }
            } catch {
                print("Failed to wait before adding a new tab: \(error)")
            }
        }
    }
    
    func handleCachedTabRemove(_ tab: Tab) async {
        // if it is a last tab - replace it with a tab with default content
        // browser can't function without at least one tab
        // so, this is kind of a side effect of removing the only one last tab
        if tabs.count == 1 {
            tabs.removeAll()
            tabsCountInput.yield(0)
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
            tabsCountInput.yield(tabs.count)
            
            guard let selectedTab = tabs[safe: newIndex] else {
                fatalError("Failed to find new selected tab")
            }
            selectedTabIdentifier = selectedTab.id
            selectedTabIdInput.yield(selectedTab.id)
        }
    }
    
    func fetchTabs() async throws {
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
        tabsCountInput.yield(cachedTabs.count)
        selectedTabIdentifier = id
        selectedTabIdInput.yield(id)
    }
    
    func subscribeForTabsCountChange() {
        // This method can't be async, have to use new Task
        Task {
            for await newTabsCount in tabsCountStream {
                for observer in self.tabObservers {
                    await observer.updateTabsCount(with: newTabsCount)
                }
            }
        }
    }
    
    func subscribeForSelectedTabIdChange() {
        // This method can't be async - it blocks init,
        // so have to use new task to avoid this.
        Task {
            let filteredId = selectedTabIdStream.drop(while: { [weak self] identifier in
                guard let self else {
                    return false
                }
                return identifier == self.positioning.defaultSelectedTabId
            })
            
            for await newSelectedTabId in filteredId {
                guard let tabTuple = tabs.element(by: newSelectedTabId) else {
                    continue
                }
                for observer in tabObservers {
                    await observer.tabDidSelect(tabTuple.index, tabTuple.tab.contentType, tabTuple.tab.id)
                }
            }
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
                _ currentlySelectedId: UUID) -> (Int, [Tab]) {
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
