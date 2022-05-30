//
//  TabsObserver.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 5/28/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation

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
