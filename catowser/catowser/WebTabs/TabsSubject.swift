//
//  TabsSubject.swift
//  catowser
//
//  Created by Andrei Ermoshin on 28/01/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import ReactiveSwift

/// MARK: Tabs observer protocol.
public protocol TabsObserver {
    /// To be able to search specific observer.
    var name: String { get }
    /// Updates observer with tabs count.
    ///
    /// - Parameter tabsCount: New number of tabs.
    func update(with tabsCount: Int)
    /// Tells other observers about new tab.
    /// We can pause drawing new tab on view layer
    /// to be able firstly determine type of initial tab state.
    ///
    /// - parameters:
    ///     - tab: new tab
    ///     - index: where to add new object
    func tabDidAdd(_ tab: Tab, at index: Int)
    /// Tells observer that index has changed.
    ///
    /// - parameters:
    ///     - index: new selected index.
    ///     - content: Tab content, e.g. can be site. Need to pass it to allow browser to change content in web view.
    func didSelect(index: Int, content: Tab.ContentType)
    /// Notifies about tab content type changes or `site` changes
    func tabDidReplace(_ tab: Tab, at index: Int)

    /// No need to add delegate methods for tab close case.
    /// because anyway view must be removed right away.
}

// Marks optional functions for protocol
public extension TabsObserver {
    var name: String {
        return String(describing: self)
    }

    func didSelect(index: Int, content: Tab.ContentType) {
        // Only landscape/regular tabs list view use that
    }

    func tabDidAdd(_ tab: Tab, at index: Int) {
        // e.g. Counter view doesn't need to handle that
        // as it uses another delegate method with `tabsCount`
    }

    /* optional */ func tabDidReplace(_ tab: Tab, at index: Int) {}

    /* optional */ func update(with tabsCount: Int) {}
}

public protocol TabsSubject {
    /// Add tabs observer.
    func attach(_ observer: TabsObserver)
    /// Removes tabs observer.
    func detach(_ observer: TabsObserver)
    /// Adds tab to memory and storage. Tab can be blank or it can contain URL address.
    /// Tab will be added no matter what happen, so, function doesn't return any result.
    ///
    /// - Parameter tab: A tab.
    func add(tab: Tab)
    /// Closes tab.
    func close(tab: Tab)
    /// Closes all tabs.
    func closeAll()
    /// Remembers selected tab index. Can fail silently if `tab` will not be found in a list.
    func select(tab: Tab)
    /// Convinient method to select a tab when you don't have `Tab` object at place.
    ///
    /// - Returns: selected tab or nothing if it was not found.
    func selectTab(at indexPath: IndexPath) -> Tab?
    /// Replaces currently active tab by combining two operations
    func replaceSelectedTab(with tab: Tab) throws
    /// Fetches latest tabs.
    func fetch() -> [Tab]
}

public final class TabsListManager {
    // Can't really implement this in Singletone pattern due to
    // asynс initialization for several parameters during init.
    // http://blog.stephencleary.com/2013/01/async-oop-2-constructors.html
    // But if we choose some default state for this object we can make async init.
    // One empty tab (`.blank` or even tab with favorite sites) will be good default
    // state for time before some cached tabs will be fetched from storage.

    /// Instance.
    public static let shared = TabsListManager(storage: TabsCacheProvider.shared)

    private let tabs: MutableProperty<[Tab]>
    private let selectedTabIndex: MutableProperty<Int>

    private let storage: TabsStorage
    private var observers: [TabsObserver] = [TabsObserver]()
    private let queue: DispatchQueue
    private lazy var scheduler: QueueScheduler = {
        let s = QueueScheduler(targeting: queue)
        return s
    }()

    private var disposables = [Disposable?]()

    init(storage: TabsStorage) {
        tabs = MutableProperty<[Tab]>([])
        selectedTabIndex = MutableProperty<Int>(-1)

        self.storage = storage
        queue = DispatchQueue(label: .queueNameWith(suffix: "tabsListSubject"))

        disposables.append(storage.fetch()
            .observe(on: scheduler)
            .startWithResult { [weak self] result in
                switch result {
                case .success(let tabsArray):
                    guard let `self` = self else { return }
                    self.tabs.value = tabsArray
                    // Temp workaround
                    self.selectedTabIndex.value = 0
                case .failure(let error):
                    print("not complete async init of \(TabsListManager.self): \(error)")
                }
        })

        disposables.append(storage.fetchSelectedIndex()
            .observe(on: scheduler)
            .startWithResult({ [weak self] result in
                switch result {
                case .success(let index):
                    guard let `self` = self else { return }
                    self.selectedTabIndex.value = index
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

extension TabsListManager: TabsSubject {
    public func fetch() -> [Tab] {
        return tabs.value
    }

    public func close(tab: Tab) {
        // if it is last tab - replace it with blank one
        if tabs.value.count == 1 {
            assert(tab == tabs.value.first!, "closing unexpected tab")
            resetToOneTab()
            // No need to change selected index because it is already 0
            // selectedTabIndex.value = 0
            return
        }

        let currentlySelected = selectedTabIndex.value
        if let tabIndex = tabs.value.firstIndex(of: tab) {
            if currentlySelected == tabIndex {
                // find if we're closing selected tab
                // select next - same behaviour is in Firefox for ios
                if tabIndex == tabs.value.count - 1 {
                    selectedTabIndex.value = tabIndex - 1
                }
                // if it is not last index, then it is automatically will become next index as planned
            } else {
                if tabIndex < currentlySelected {
                    selectedTabIndex.value = currentlySelected - 1
                }
                // for opposite case it will stay the same
            }
            tabs.value.remove(at: tabIndex)
        }
        
    }

    public func closeAll() {
        resetToOneTab()
        selectedTabIndex.value = 0
    }

    public func add(tab: Tab) {
        let newIndex: Int
        switch DefaultTabProvider.shared.defaultPosition {
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

    public func replaceSelectedTab(with tab: Tab) throws {
        let index = selectedTabIndex.value
        guard index >= 0 else {
            throw NotInitializedYet()
        }

        tabs.value[index] = tab

        // Need to notify observers to allow them
        // to update title for tab view
        DispatchQueue.main.async {
            self.observers.forEach { $0.tabDidReplace(tab, at: index) }
        }
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
        let tab: Tab = .initial

        tabs.value.append(tab)
        selectedTabIndex.value = 0

        switch DefaultTabProvider.shared.addSpeed {
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
