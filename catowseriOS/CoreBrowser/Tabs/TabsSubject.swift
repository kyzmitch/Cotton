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
    /// Add tabs observer. Notifies the new observer right away with existing data if needed.
    /// - Parameter observer: A new observer to notify from this subject
    /// - Parameter notify: Tells if newly added observer needs to be notified right away
    func attach(_ observer: TabsObserver, notify: Bool) async
    /// Removes tabs observer.
    func detach(_ observer: TabsObserver) async
    /// Adds tab to memory and storage. Tab can be blank or it can contain URL address.
    /// Tab will be added no matter what happen, so, function doesn't return any result.
    ///
    /// - Parameter tab: A tab.
    func add(tab: Tab) async
    /// Closes tab.
    func close(tab: Tab) async
    /// Closes all tabs.
    func closeAll() async
    /// Remembers selected tab index. Can fail silently if `tab` is not found in a list.
    func select(tab: Tab) async
    /// Replaces currently active tab by combining two operations
    func replaceSelected(_ tabContent: Tab.ContentType) async throws
    /// Returns tabs count
    var tabsCount: Int { get async }
    /// Returns selected UUID, could be invalid one which is defined (to handle always not empty condition)
    var selectedId: UUID { get async }
    /// Fetches latest tabs.
    var allTabs: [Tab] { get async }
}
