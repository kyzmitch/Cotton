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
    private let selectedTabIndex: MutableProperty<Int>

    private let storage: TabsStoragable
    private let positioning: TabsPositioning
    private var observers: [TabsObserver] = [TabsObserver]()
    private let queue: DispatchQueue
    private lazy var scheduler: QueueScheduler = {
        let s = QueueScheduler(targeting: queue)
        return s
    }()

    private var disposables = [Disposable?]()

    // swiftlint:disable:next function_body_length
    public init(storage: TabsStoragable, positioning: TabsPositioning) {
        selectionStrategy = NearbySelectionStrategy()

        tabs = MutableProperty<[Tab]>([])
        selectedTabIndex = MutableProperty<Int>(-1)

        self.storage = storage
        self.positioning = positioning
        queue = DispatchQueue(label: .queueNameWith(suffix: "tabsListSubject"))

        // Temporarily delay to wait before first `observer` will be added
        // to send data from storage to it
        let delay = TimeInterval(1)
        
        disposables.append(storage.fetchAllTabs()
            .delay(delay, on: scheduler)
            .observe(on: scheduler)
            .startWithResult { [weak self] result in
                switch result {
                case .success(let tabsArray):
                    guard let `self` = self else { return }
                    self.tabs.value = tabsArray
                    // for .pad tabs view observable to render all tabs at once
                    // this isn't necessary for .phone because different tabs screen is used
                    // also, it's better than adding tab one by one
                    let disposable = UIScheduler().schedule({ [weak self] in
                        // actually only one observer will use it
                        self?.observers.forEach { $0.initializeObserver(with: tabsArray) }
                    })
                    guard let initialDisposable = disposable else {
                        return
                    }
                    self.disposables.append(initialDisposable)
                case .failure(let error):
                    print("not complete async init of \(TabsListManager.self): \(error)")
                }
        })

        disposables.append(storage.fetchSelectedIndex()
            .delay(delay, on: scheduler)
            .observe(on: scheduler)
            .startWithResult({ [weak self] result in
                switch result {
                case .success(let index):
                    guard let `self` = self else { return }
                    // need to wait before tabs fetch will be finished
                    self.selectedTabIndex.value = Int(index)
                case .failure(let error):
                    print("not complete async init of \(TabsListManager.self): \(error)")
                }
        }))

        disposables.append(self.tabs.signal
            .map { $0.count }
            .observe(on: UIScheduler())
            .observeValues { [weak self] tabsCount in
                guard let `self` = self else {
                    return
                }

                self.observers.forEach { $0.update(with: tabsCount) }
        })

        disposables.append(selectedTabIndex.signal
            .observe(on: UIScheduler())
            .observeValues { [weak self] newIndex in
                guard let `self` = self else {
                    return
                }
                // already selected tab can be selected again
                // so, need to think about Tab.visualState and remove it
                // and use only selectedTabIndex or implement some check
                // here to not notify observers
                let tab = self.tabs.value[newIndex]
                self.observers.forEach { $0.didSelect(index: newIndex, content: tab.contentType) }
        })
    }

    deinit {
        disposables.forEach { $0?.dispose() }
    }

    public var tabsCount: Int {
        return self.tabs.value.count
    }

    /// Returns currently selected tab. We have to use Optional type
    public func selectedTab() throws -> Tab {
        let index = selectedTabIndex.value
        guard index >= 0 else {
            throw NotInitializedYet()
        }

        return tabs.value[index]
    }

    fileprivate struct NotInitializedYet: Error {}
}

extension TabsListManager: IndexSelectionContext {
    public var collectionLastIndex: Int {
        // -1 index is not possible because always should be at least 1 tab
        return tabs.value.count - 1
    }

    public var currentlySelectedIndex: Int {
        return selectedTabIndex.value
    }
}

extension TabsListManager: TabsSubject {
    public func fetch() -> [Tab] {
        return tabs.value
    }

    public func close(tab: Tab) {
        // if it is last tab - replace it with blank one
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
        selectedTabIndex.value = newIndex
    }

    public func closeAll() {
        resetToOneTab()
        selectedTabIndex.value = 0
    }

    public func add(tab: Tab) {
        let newIndex: Int
        switch positioning.addPosition {
        case .listEnd:
            tabs.value.append(tab)
            newIndex = tabs.value.count - 1
            if tab.visualState == .selected {
                selectedTabIndex.value = newIndex
            }
        case .afterSelected:
            newIndex = selectedTabIndex.value + 1
            tabs.value.insert(tab, at: newIndex)
            if tab.visualState == .selected {
                selectedTabIndex.value = newIndex
            }
        }

        storage.add(tab: tab)
        DispatchQueue.main.async {
            self.observers.forEach { $0.tabDidAdd(tab, at: newIndex) }
        }
    }

    public func select(tab: Tab) {
        guard let index = tabs.value.firstIndex(of: tab) else {
            return
        }
        _ = storage.select(tab: tab)
        selectedTabIndex.value = index
    }

    public func replaceSelected(tabContent: Tab.ContentType) throws {
        let index = selectedTabIndex.value

        guard var selectedTab = tabs.value[safe: index] else {
            throw NotInitializedYet()
        }

        selectedTab.contentType = tabContent
        // we must reset preview
        selectedTab.preview = nil
        tabs.value[index] = selectedTab

        // Need to notify observers to allow them
        // to update title for tab view
        DispatchQueue.main.async {
            self.observers.forEach { $0.tabDidReplace(selectedTab, at: index) }
        }
    }
    
    /// Updates preview image for selected tab if it has site content.
    ///
    /// - Parameter image: `UIImage` usually a screenshot of WKWebView.
    public func setSelectedPreview(_ image: UIImage?) throws {
        let index = selectedTabIndex.value
        
        guard var selectedTab = tabs.value[safe: index] else {
            throw NotInitializedYet()
        }
        if case .site = selectedTab.contentType, image == nil {
            struct WrongTabContent: Error {}
            throw WrongTabContent()
        }
        selectedTab.preview = image
        tabs.value[index] = selectedTab
    }

    public func selectTab(at indexPath: IndexPath) -> Tab? {
        // item property is used because `UICollectionView` used
        guard let tab = tabs.value[safe: indexPath.item] else {
            return nil
        }

        _ = storage.select(tab: tab)
        selectedTabIndex.value = indexPath.item
        return tab
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
        selectedTabIndex.value = 0

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
