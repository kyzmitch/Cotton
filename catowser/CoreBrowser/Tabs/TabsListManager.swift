//
//  TabsListManager.swift
//  catowser
//
//  Created by Andrei Ermoshin on 28/01/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import ReactiveSwift

public final class TabsListManager {
    // Can't really implement this in Singletone pattern due to
    // asynс initialization for several parameters during init.
    // http://blog.stephencleary.com/2013/01/async-oop-2-constructors.html
    // But if we choose some default state for this object we can make async init.
    // One empty tab (`.blank` or even tab with favorite sites) will be good default
    // state for time before some cached tabs will be fetched from storage.

    /// Current tab selection strategy
    public var selectionStrategy: TabSelectionStrategy

    private let tabs: MutableProperty<[Tab]>
    private let selectedTabId: MutableProperty<UUID>

    private let storage: TabsStoragable
    private let positioning: TabsPositioning
    private var observers: [TabsObserver] = [TabsObserver]()
    private let queue: DispatchQueue
    private lazy var scheduler: QueueScheduler = {
        let internalSheduler = QueueScheduler(targeting: queue)
        return internalSheduler
    }()

    private var disposables = [Disposable?]()
    private var tabAddDisposable: Disposable?
    private var tabCloseDisposable: Disposable?
    private var tabSelectDisposable: Disposable?
    private var tabContentUpdateDisposable: Disposable?

    public init(storage: TabsStoragable, positioning: TabsPositioning) {
        selectionStrategy = NearbySelectionStrategy()

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
                self.observers.forEach { $0.didSelect(index: tabTuple.index, content: tabTuple.tab.contentType, identifier: tabTuple.tab.id) }
        }
        disposables.append(disposable)
    }

    public var tabsCount: Int {
        return self.tabs.value.count
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
    
    public var selectedId: UUID {
        return selectedTabId.value
    }

    fileprivate enum TabsListError: LocalizedError {
        case notInitializedYet
        case selectedNotFound
        case wrongTabContent
    }
}

extension TabsListManager: IndexSelectionContext {
    public var collectionLastIndex: Int {
        // -1 index is not possible because always should be at least 1 tab
        let amount = tabs.value.count
        assert(amount != 0, "Tabs amount shouldn't be 0")
        return amount - 1
    }

    public var currentlySelectedIndex: Int {
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
        resetToOneTab()
        selectedTabId.value = positioning.defaultSelectedTabId
    }

    public func add(tab: Tab) {
        let newIndex = positioning.addPosition.addTab(tab, to: tabs, currentlySelectedId: selectedId)
        let selectedIndexAfterAdd = selectionStrategy.autoSelectedIndexAfterTabAdd(self, addedIndex: newIndex)
        let needSelect = selectedIndexAfterAdd == newIndex
        tabAddDisposable?.dispose()
        tabAddDisposable = storage
            .add(tab: tab, andSelect: needSelect)
            .startWithResult { [weak self] (result) in
                switch result {
                case .failure(let storageError):
                    // It doesn't matter, on view level it must be added right away
                    print("Failed to add this tab to cache: \(storageError)")
                case .success(let addedTab):
                    guard let self = self else { return }
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.observers.forEach { $0.tabDidAdd(tab, at: newIndex) }
                        // can select new tab only after adding it
                        // this is because corresponding view should be in the list
                        // before that
                        if needSelect {
                            self.selectedTabId.value = addedTab.id
                        }
                    }
                }
            }
    }

    public func select(tab: Tab) {
        tabSelectDisposable?.dispose()
        tabSelectDisposable = storage
            .select(tab: tab)
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

    public func replaceSelected(tabContent: Tab.ContentType) throws {
        guard var tabTuple = tabs.value.element(by: selectedId) else {
            throw TabsListError.notInitializedYet
        }
        
        tabTuple.tab.contentType = tabContent
        // we must reset preview
        tabTuple.tab.preview = nil
        // TODO: not sure if it is needed
        tabs.value[tabTuple.index] = tabTuple.tab
        
        tabContentUpdateDisposable?.dispose()
        tabContentUpdateDisposable = storage
            .update(tab: tabTuple.tab)
            .startWithResult({ (result) in
                if case .failure(let storageError) = result {
                    print("Failed to update tab content to storage \(storageError)")
                }
            })
        // Need to notify observers to allow them
        // to update title for tab view
        DispatchQueue.main.async {
            self.observers.forEach { $0.tabDidReplace(tabTuple.tab, at: tabTuple.index) }
        }
    }
    
    /// Updates preview image for selected tab if it has site content.
    ///
    /// - Parameter image: `UIImage` usually a screenshot of WKWebView.
    public func setSelectedPreview(_ image: UIImage?) throws {
        guard let tabTuple = tabs.value.element(by: selectedId) else {
            throw TabsListError.notInitializedYet
        }
        if case .site = tabTuple.tab.contentType, image == nil {
            throw TabsListError.wrongTabContent
        }
        var tabCopy = tabTuple.tab
        tabCopy.preview = image
        tabs.value[tabTuple.index] = tabCopy
    }

    public func attach(_ observer: TabsObserver) {
        queue.async { [weak self] in
            self?.observers.append(observer)
        }
    }

    public func detach(_ observer: TabsObserver) {
        queue.async { [weak self] in
            self?.observers.removeAll { (currentObserver) -> Bool in
                return currentObserver.name == observer.name
            }
        }
    }
}

private extension TabsListManager {
    func resetToOneTab() {
        tabs.value.removeAll()
        let newTabId = self.positioning.defaultSelectedTabId
        let tab: Tab = .init(contentType: positioning.contentState, idenifier: newTabId)

        tabs.value.append(tab)
        // No need to change selected index because it is already 0
        // but it is needed to update web view content
        selectedTabId.value = newTabId

        switch positioning.addSpeed {
        case .immediately:
            DispatchQueue.main.async { [weak self] in
                self?.observers.forEach {
                    $0.tabDidAdd(tab, at: 0)
                }
            }
        case .after(let interval):
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + interval) { [weak self] in
                self?.observers.forEach {
                    $0.tabDidAdd(tab, at: 0)
                }
            }
        }
    }
    
    func handleCachedTabRemove(_ tab: Tab) {
        // if it is a last tab - replace it with a tab with default content
        // browser can't function without at least one tab
        // so, this is kind of a side effect of removing the only one last tab
        if tabs.value.count == 1, let firstTab = tabs.value.first {
            assert(tab == firstTab, "closing unexpected tab")
            resetToOneTab()
            return
        }

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

extension Array where Element == Tab {
    func element(by uuid: UUID) -> (tab: Tab, index: Int)? {
        for (ix, tab) in self.enumerated() where tab.id == uuid {
            return (tab, ix)
        }
        return nil
    }
}
