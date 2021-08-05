//
//  TabsSubjectObserver.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 5/28/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import ReactiveSwift

/// Describes how new tab is added to the list.
/// Uses `Int` as raw value to be able to store it in settings.
public enum AddedTabPosition: Int, CaseIterable {
    case listEnd = 0
    case afterSelected = 1
    
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

public enum TabAddSpeed {
    case immediately
    case after(DispatchTimeInterval)
}

/// MARK: Tabs observer protocol.
public protocol TabsObserver {
    /// To be able to search specific observer.
    var name: String { get }
    /// Updates observer with tabs count.
    ///
    /// - Parameter tabsCount: New number of tabs.
    func update(with tabsCount: Int)
    /// Prodive necessary data to render UI on tablets
    ///
    /// - Parameter tabs: Tabs from cache at application start.
    func initializeObserver(with tabs: [Tab])
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
    ///     - identifier: needed to quickly determine visual state (selected view or not)
    func didSelect(index: Int, content: Tab.ContentType, identifier: UUID)
    /// Notifies about tab content type changes or `site` changes
    func tabDidReplace(_ tab: Tab, at index: Int)

    /// No need to add delegate methods for tab close case.
    /// because anyway view must be removed right away.
}

/// Marks optional functions for protocol
/// because `optional` keyword can be only used for objc types
public extension TabsObserver {
    var name: String {
        return String(describing: self)
    }

    func didSelect(index: Int, content: Tab.ContentType, identifier: UUID) {
        // Only landscape/regular tabs list view use that
    }

    func tabDidAdd(_ tab: Tab, at index: Int) {
        // e.g. Counter view doesn't need to handle that
        // as it uses another delegate method with `tabsCount`
    }

    /* optional */ func tabDidReplace(_ tab: Tab, at index: Int) {}

    /* optional */ func update(with tabsCount: Int) {}

    /* optional */ func initializeObserver(with tabs: [Tab]) {}
}

public protocol TabsPositioning {
    var addPosition: AddedTabPosition { get }
    var contentState: Tab.ContentType { get }
    var addSpeed: TabAddSpeed { get }
    var defaultSelectedTabId: UUID { get }
}

/// Twin type for `Tab.ContentType` to have `rawValue`
/// and use it for settings.
public enum TabContentDefaultState: Int, CaseIterable, CustomStringConvertible {
    case blank
    case homepage
    case favorites
    case topSites
    
    public var contentType: Tab.ContentType {
        switch self {
        case .blank:
            return .blank
        case .homepage:
            return .homepage
        case .favorites:
            return .favorites
        case .topSites:
            return .topSites
        }
    }
    
    public var description: String {
        let key: String
        
        switch self {
        case .blank:
            key = "txt_tab_content_blank"
        case .homepage:
            key = "txt_tab_content_homepage"
        case .favorites:
            key = "txt_tab_content_favorites"
        case .topSites:
            key = "txt_tab_content_top_sites"
        }
        return NSLocalizedString(key, comment: "")
    }
}

public enum TabSubjectError: Error {
    case tabSelectionFailure
}

public protocol TabsSubject {
    init(storage: TabsStoragable, positioning: TabsPositioning)
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
    /// Replaces currently active tab by combining two operations
    func replaceSelected(tabContent: Tab.ContentType) throws
    /// Fetches latest tabs.
    func fetch() -> [Tab]
}
