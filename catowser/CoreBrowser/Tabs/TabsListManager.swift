//
//  TabsListManager.swift
//  catowser
//
//  Created by Andrei Ermoshin on 28/01/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import ReactiveSwift

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
 */
public final class TabsListManager {
    /// Current tab selection strategy
    var selectionStrategy: TabSelectionStrategy

    private let tabs: MutableProperty<[Tab]>
    private let selectedTabId: MutableProperty<UUID>

    private let storage: TabsStoragable
    private let positioning: TabsStates
    private var observers: [TabsObserver] = [TabsObserver]()
    private let queue: DispatchQueue
    private lazy var scheduler: QueueScheduler = {
        let internalSheduler = QueueScheduler(targeting: queue)
        return internalSheduler
    }()

    private var disposables = [Disposable?]()
    private var tabAddDisposable: Disposable?
    private var tabCloseDisposable: Disposable?
    private var closeAllTabsDisposable: Disposable?
    private var tabSelectDisposable: Disposable?
    private var tabContentUpdateDisposable: Disposable?

    public init(storage: TabsStoragable, positioning: TabsStates, selectionStrategy: TabSelectionStrategy) {
        self.selectionStrategy = selectionStrategy

        tabs = MutableProperty<[Tab]>([])
        selectedTabId = MutableProperty<UUID>(positioning.defaultSelectedTabId)

        self.storage = storage
        self.positioning = positioning
        queue = DispatchQueue(label: .queueNameWith(suffix: "tabsListSubject"))

        // Temporarily delay to wait before first `observer` will be added
        // to send data from storage to it
        let delay = TimeInterval(1)
        
        subscribeForTabsCountChange()
        subscribeForSelectedTabIdChange()
        initTabs(with: delay)
    }

    deinit {
        disposables.forEach { $0?.dispose() }
    }
    
    func initTabs(with delay: TimeInterval) {
        let disposable = storage.fetchAllTabs()
            .delay(delay, on: scheduler)
            .flatMap(.latest, { [weak self] (tabs) -> SignalProducer<[Tab], TabStorageError> in
                guard let `self` = self else {
                    return .init(error: .zombieSelf)
                }
                guard tabs.isEmpty else {
                    return .init(value: tabs)
                }
                let tab = Tab(contentType: self.positioning.contentState)
                return self.storage.add(tab: tab, andSelect: true).map {[$0]}
            })
            .flatMap(.latest, { [weak self] (tabs) -> SignalProducer<([Tab], UUID), TabStorageError> in
                guard let `self` = self else {
                    return .init(error: .zombieSelf)
                }
                return self.storage.fetchSelectedTabId().map {(tabs, $0)}
            })
            .observe(on: scheduler)
            .startWithResult { [weak self] result in
                switch result {
                case .success(let tuple):
                    guard let `self` = self else { return }
                    let tabsArray = tuple.0
                    let tabIdentifier = tuple.1
                    guard !tabsArray.isEmpty else {
                        return
                    }
                    self.tabs.value = tabsArray
                    let disposable = UIScheduler().schedule({ [weak self] in
                        // actually only one observer will use it
                        self?.observers.forEach { $0.initializeObserver(with: tabsArray) }
                    })
                    // update selected tab index only after initializing observers with current tabs
                    self.selectedTabId.value = tabIdentifier
                    guard let initialDisposable = disposable else {
                        return
                    }
                    self.disposables.append(initialDisposable)
                case .failure(let error):
                    print("Failed to fetch tabs from storage or no tabs at all: \(TabsListManager.self): \(error)")
                }
        }
        
        disposables.append(disposable)
    }
    
    func subscribeForTabsCountChange() {
        let disposable = tabs.signal
            .skipRepeats({ (old, new) -> Bool in
                return old.count == new.count
            })
            .map { $0.count }
            .observe(on: UIScheduler())
            .observeValues { [weak self] tabsCount in
                guard let `self` = self else {
                    return
                }

                self.observers.forEach { $0.update(with: tabsCount) }
        }
        disposables.append(disposable)
    }
    
    func subscribeForSelectedTabIdChange() {
        let disposable = selectedTabId.signal
            .observe(on: UIScheduler())
            .observeValues { [weak self] newSelectedTabId in
                guard let `self` = self else {
                    return
                }
                guard let tabTuple = self.tabs.value.element(by: newSelectedTabId) else {
                    return
                }
                self.observers.forEach { $0.tabDidSelect(index: tabTuple.index,
                                                         content: tabTuple.tab.contentType,
                                                         identifier: tabTuple.tab.id) }
        }
        disposables.append(disposable)
    }

    /// Returns currently selected tab.
    public func selectedTab() throws -> Tab {
        guard selectedId != self.positioning.defaultSelectedTabId else {
            throw TabsListError.notInitializedYet
        }

        guard let tabTuple = tabs.value.element(by: selectedId) else {
            throw TabsListError.selectedNotFound
        }
        return tabTuple.tab
    }
    
    /// Returns index of selected tab
    public func selectedIndex() throws -> Int {
        guard let tabTuple = tabs.value.element(by: selectedId) else {
            throw TabsListError.notInitializedYet
        }
        return tabTuple.index
    }
    
    /// Replaces tab at specific index
    public func replaceInMemory(_ tab: Tab, _ index: Int) throws {
        guard index >= 0 && index < tabs.value.count else {
            throw TabsListError.wrongTabIndexToReplace
        }
        tabs.value[index] = tab
    }
}

extension TabsListManager: IndexSelectionContext {
    public var collectionLastIndex: Int {
        // -1 index is not possible because always should be at least 1 tab
        let amount = tabs.value.count
        // Leaving assert even with unit tests
        // https://stackoverflow.com/a/410198
        assert(amount != 0, "Tabs amount shouldn't be 0")
        return amount - 1
    }

    public var currentlySelectedIndex: Int {
        // Leaving assert even with unit tests
        // https://stackoverflow.com/a/410198
        assert(!tabs.value.isEmpty, "Tabs amount shouldn't be 0")
        if let tabTuple = tabs.value.element(by: selectedId) {
            return tabTuple.index
        }
        // tabs collection shouldn't be empty, so,
        // it is safe to return index of 1st element
        return 0
    }
}

extension TabsListManager: TabsSubject {
    public func fetch() -> [Tab] {
        return tabs.value
    }

    public func close(tab: Tab) {
        tabCloseDisposable?.dispose()
        tabCloseDisposable = storage
            .remove(tab: tab)
            .observe(on: scheduler)
            .startWithResult({ [weak self] (result) in
                switch result {
                case .failure(let storageError):
                    // tab view should be removed immediately on view level anyway
                    print("Failure to remove tab from cache: \(storageError)")
                case .success(let removedTab):
                    self?.handleCachedTabRemove(removedTab)
                }
        })
    }

    public func closeAll() {
        // Should always work, don't care about errors
        typealias TabAddProducer = SignalProducer<Tab, TabStorageError>
        
        closeAllTabsDisposable?.dispose()
        closeAllTabsDisposable = storage
            .remove(tabs: tabs.value)
            .flatMap(.latest, { [weak self] _ -> TabAddProducer in
                guard let self = self else {
                    return .init(error: TabStorageError.zombieSelf)
                }
                self.tabs.value.removeAll()
                let tab: Tab = .init(contentType: self.positioning.contentState)
                return self.storage.add(tab: tab, andSelect: true)
            })
            .observe(on: scheduler)
            .startWithResult({ [weak self] (result) in
                switch result {
                case .failure(let storageError):
                    // tab view should be removed immediately on view level anyway
                    print("Failure to remove tab and reset to one tab: \(storageError)")
                case .success(let addedTab):
                    guard let self = self else { return }
                    self.handleTabAdded(addedTab, index: 0, select: true)
                }
        })
    }

    public func add(tab: Tab) {
        let newIndex = positioning.addPosition.addTab(tab, to: tabs, currentlySelectedId: selectedId)
        let needSelect = selectionStrategy.makeTabActiveAfterAdding
        tabAddDisposable?.dispose()
        tabAddDisposable = storage
            .add(tab: tab, andSelect: needSelect)
            .observe(on: scheduler)
            .startWithResult { [weak self] (result) in
                switch result {
                case .failure(let storageError):
                    // It doesn't matter, on view level it must be added right away
                    print("Failed to add this tab to cache: \(storageError)")
                case .success(let addedTab):
                    guard let self = self else { return }
                    self.handleTabAdded(addedTab, index: newIndex, select: needSelect)
                }
            }
    }

    public func select(tab: Tab) {
        tabSelectDisposable?.dispose()
        tabSelectDisposable = storage
            .select(tab: tab)
            .observe(on: scheduler)
            .startWithResult({ [weak self] (result) in
                switch result {
                case .success(let identifier):
                    guard let self = self else { return }
                    guard identifier != self.selectedId else {
                        return
                    }
                    self.selectedTabId.value = identifier
                case .failure(let storageError):
                    print("Failed to select tab with id \(tab.id) \(storageError)")
                }
            })
    }

    public func replaceSelected(_ tabContent: Tab.ContentType) throws {
        guard let tabTuple = tabs.value.element(by: selectedId) else {
            throw TabsListError.notInitializedYet
        }
        guard tabTuple.tab.contentType != tabContent else {
            return
        }
        var newTab = tabTuple.tab
        let tabIndex = tabTuple.index
        newTab.contentType = tabContent
        newTab.previewData = nil
        
        tabContentUpdateDisposable?.dispose()
        tabContentUpdateDisposable = storage
            .update(tab: newTab)
            .observe(on: UIScheduler())
            .startWithResult({ [weak self] (result) in
                switch result {
                case .success:
                    self?.tabs.value[tabIndex] = newTab
                    // Need to notify observers to allow them
                    // to update title for tab view
                    self?.observers.forEach { $0.tabDidReplace(newTab, at: tabIndex) }
                case .failure(let storageError):
                    print("Failed to update tab content to storage \(storageError)")
                }
            })
    }

    public func attach(_ observer: TabsObserver, notify: Bool = false) {
        queue.async { [weak self] in
            self?.observers.append(observer)
        }
        if notify {
            if selectedId != positioning.defaultSelectedTabId {
                if let tabTuple = tabs.value.element(by: selectedId) {
                    observer.tabDidSelect(index: tabTuple.index,
                                          content: tabTuple.tab.contentType,
                                          identifier: tabTuple.tab.id)
                }
            }
            // could notify about some other events in addition
        }
    }

    public func detach(_ observer: TabsObserver) {
        queue.async { [weak self] in
            self?.observers.removeAll { (currentObserver) -> Bool in
                return currentObserver.name == observer.name
            }
        }
    }
    
    public var tabsCount: Int {
        return self.tabs.value.count
    }
    
    public var selectedId: UUID {
        return selectedTabId.value
    }
}

private extension TabsListManager {
    func handleTabAdded(_ tab: Tab, index: Int, select: Bool) {
        // can select new tab only after adding it
        // this is because corresponding view should be in the list
        
        switch positioning.addSpeed {
        case .immediately:
            DispatchQueue.main.async { [weak self] in
                self?.observers.forEach {
                    $0.tabDidAdd(tab, at: index)
                }
                if select {
                    self?.selectedTabId.value = tab.id
                }
            }
        case .after(let interval):
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + interval) { [weak self] in
                self?.observers.forEach {
                    $0.tabDidAdd(tab, at: index)
                }
                if select {
                    self?.selectedTabId.value = tab.id
                }
            }
        }
    }
    
    func handleCachedTabRemove(_ tab: Tab) {
        // if it is a last tab - replace it with a tab with default content
        // browser can't function without at least one tab
        // so, this is kind of a side effect of removing the only one last tab
        if tabs.value.count == 1 {
            tabs.value.removeAll()
            let tab: Tab = .init(contentType: positioning.contentState)
            add(tab: tab)
        } else {
            guard let closedTabIndex = tabs.value.firstIndex(of: tab) else {
                fatalError("Closing non existing tab")
            }

            let newIndex = selectionStrategy.autoSelectedIndexAfterTabRemove(self, removedIndex: closedTabIndex)
            // need to remove it before changing selected index
            // otherwise in one case the handler will select closed tab
            tabs.value.remove(at: closedTabIndex)
            
            guard let selectedTab = tabs.value[safe: newIndex] else {
                fatalError("Failed to find new selected tab")
            }
            self.selectedTabId.value = selectedTab.id
        }
    }
}

extension Array where Element == Tab {
    func element(by uuid: UUID) -> (tab: Tab, index: Int)? {
        for (ix, tab) in self.enumerated() where tab.id == uuid {
            return (tab, ix)
        }
        return nil
    }
}

extension AddedTabPosition {
    func addTab(_ tab: Tab,
                to tabs: MutableProperty<[Tab]>,
                currentlySelectedId: UUID) -> Int {
        let newIndex: Int
        switch self {
        case .listEnd:
            tabs.value.append(tab)
            newIndex = tabs.value.count - 1
        case .afterSelected:
            guard let tabTuple = tabs.value.element(by: currentlySelectedId) else {
                // no previously selected tab, probably when reset to one tab happend
                tabs.value.append(tab)
                return tabs.value.count - 1
            }
            newIndex = tabTuple.index + 1
            tabs.value.insert(tab, at: newIndex)
        }
        
        return newIndex
    }
}
