//
//  TabsSubject.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 5/30/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation

public enum TabSubjectError: Error {
    case tabSelectionFailure
}

public protocol TabsSubject {
    /// Tabs subject initialiser for Observer pattern
    init(storage: TabsStoragable, positioning: TabsStates, selectionStrategy: TabSelectionStrategy)
    /// Add tabs observer. Notifies the new observer right away with existing data if needed.
    /// - Parameter observer: A new observer to notify from this subject
    /// - Parameter notify: Tells if newly added observer needs to be notified right away
    func attach(_ observer: TabsObserver, notify: Bool)
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
    /// Remembers selected tab index. Can fail silently if `tab` is not found in a list.
    func select(tab: Tab)
    /// Replaces currently active tab by combining two operations
    func replaceSelected(_ tabContent: Tab.ContentType) throws
    /// Fetches latest tabs.
    func fetch() -> [Tab]
    /// Returns tabs count
    var tabsCount: Int { get }
    /// Returns selected UUID, could be invalid one which is defined (to handle always not empty condition)
    var selectedId: UUID { get }
}
