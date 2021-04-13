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
        let s = QueueScheduler(targeting: queue)
        return s
    }()

    private var disposables = [Disposable?]()

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
                    self.selectedTabId.value = tabIdentifier
                    let disposable = UIScheduler().schedule({ [weak self] in
                        // actually only one observer will use it
                        self?.observers.forEach { $0.initializeObserver(with: tabsArray) }
                    })
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
                if let tabTuple = self.tabs.value.element(by: newSelectedTabId) {
                    self.observers.forEach { $0.didSelect(index: tabTuple.index, content: tabTuple.tab.contentType) }
                }
        }
        disposables.append(disposable)
    }

    public var tabsCount: Int {
        return self.tabs.value.count
    }

    /// Returns currently selected tab.
    public func selectedTab() throws -> Tab {
        let selectedId = selectedTabId.value
        guard selectedId != self.positioning.defaultSelectedTabId else {
            throw NotInitializedYet()
        }

        guard let tabTuple = tabs.value.element(by: selectedId) else {
            throw SelectedNotFound()
        }
        return tabTuple.tab
    }

    fileprivate struct NotInitializedYet: Error {}
    fileprivate struct SelectedNotFound: Error {}
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
        let tabId = selectedTabId.value
        if let tabTuple = tabs.value.element(by: tabId) {
            return tabTuple.index
        }
        // tabs collection should be empty, so,
        // it is safe to return index of 1st element
        return 0
    }
}

extension TabsListManager: TabsSubject {
    public func fetch() -> [Tab] {
        return tabs.value
    }

    public func close(tab: Tab) {
        // if it is last tab - replace it with a tab with default content
        if tabs.value.count == 1, let firstTab = tabs.value.first {
            assert(tab == firstTab, "closing unexpected tab")
            resetToOneTab()
            return
        }

        guard let tabIndex = tabs.value.firstIndex(of: tab) else {
            fatalError("closing non existing tab")
        }

        let newIndex = selectionStrategy.autoSelectedIndexBasedOn(self, removedIndex: tabIndex)
        // need to remove it before changing selected index
        // otherwise in one case the handler will select closed tab
        tabs.value.remove(at: tabIndex)
        guard let selectedTab = tabs.value[safe: newIndex] else {
            fatalError("Failed to find new selected tab")
        }
        selectedTabId.value = selectedTab.id
    }

    public func closeAll() {
        resetToOneTab()
        selectedTabId.value = positioning.defaultSelectedTabId
    }

    public func add(tab: Tab) {
        let newIndex = positioning.addPosition.addTabAndReturnIndex(tab,
                                                                    to: self.tabs,
                                                                    currentlySelectedId: selectedTabId.value)
        _ = storage.add(tab: tab, andSelect: false).startWithResult { [weak self] (result) in
            if case .failure(let storageError) = result {
                print("Failed to add a tab to storage \(storageError)")
            } else {
                if tab.visualState == .selected {
                    self?.selectedTabId.value = tab.id
                }
            }
        }
        DispatchQueue.main.async {
            self.observers.forEach { $0.tabDidAdd(tab, at: newIndex) }
        }
    }

    public func select(tab: Tab) {
        _ = storage.select(tab: tab).startWithResult({ [weak self] (result) in
            switch result {
            case .success(let identifier):
                self?.selectedTabId.value = identifier
            case .failure(let storageError):
                print("Failed to select tab with id \(tab.id) \(storageError)")
            }
        })
        
    }

    public func replaceSelected(tabContent: Tab.ContentType) throws {
        let tabId = selectedTabId.value

        guard var tabTuple = tabs.value.element(by: tabId) else {
            throw NotInitializedYet()
        }

        tabTuple.tab.contentType = tabContent
        // we must reset preview
        tabTuple.tab.preview = nil
        tabs.value[tabTuple.index] = tabTuple.tab

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
        let tabId = selectedTabId.value
        
        guard let tabTuple = tabs.value.element(by: tabId) else {
            throw NotInitializedYet()
        }
        if case .site = tabTuple.tab.contentType, image == nil {
            struct WrongTabContent: Error {}
            throw WrongTabContent()
        }
        var tabCopy = tabTuple.tab
        tabCopy.preview = image
        tabs.value[tabTuple.index] = tabCopy
    }

    public func selectTab(at indexPath: IndexPath) -> SignalProducer<Tab, TabSubjectError> {
        // item property is used because `UICollectionView` used
        guard let tab = tabs.value[safe: indexPath.item] else {
            return .init(error: .noTabAtSpecifiedIndexToSelect)
        }
        
        // Side effect
        selectedTabId.value = tab.id
        return storage.select(tab: tab)
            .mapError { (_) -> TabSubjectError in
                return .tabSelectionFailure
            }.map { (_) -> Tab in
                return tab
            }
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
        let tab: Tab = .init(contentType: positioning.contentState, selected: true)

        tabs.value.append(tab)
        // No need to change selected index because it is already 0
        // but it is needed to update web view content
        selectedTabId.value = self.positioning.defaultSelectedTabId

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
}

extension Array where Element == Tab {
    func element(by uuid: UUID) -> (tab: Tab, index: Int)? {
        // TODO: fix linear search
        for (ix, tab) in self.enumerated() where tab.id == uuid {
            return (tab, ix)
        }
        return nil
    }
}
