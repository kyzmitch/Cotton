//
//  TabSelectionStrategy.swift
//  CottonDataServices
//
//  Created by Andrei Ermoshin on 05/03/2019.
//  Copyright © 2019 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import AutoMockable

public protocol IndexSelectionContext: AutoMockable {
    var collectionLastIndex: Int { get async }
    var currentlySelectedIndex: Int { get async }
}

/// Snapshot-based `IndexSelectionContext` for selection strategy calls outside `TabsDataService`.
public struct TabsIndexSelectionSnapshot: IndexSelectionContext, Sendable {
    private let lastIndex: Int
    private let selectedIndex: Int

    public init(collectionLastIndex: Int, currentlySelectedIndex: Int) {
        self.lastIndex = collectionLastIndex
        self.selectedIndex = currentlySelectedIndex
    }

    public var collectionLastIndex: Int {
        get async { lastIndex }
    }

    public var currentlySelectedIndex: Int {
        get async { selectedIndex }
    }
}

/// CoreBrowser.Tab selection protocol can be sendable, because implementation
/// only holds a constant which can't be mutated, so that, no any mutable state for now.
public protocol TabSelectionStrategy: AutoMockable, Sendable {
    /// A CoreBrowser.Tab selection strategy (Compositor) defines the algorithms of tab selection in specific cases
    /// 1) when tab was removed and need to select another
    /// 2) tbd
    ///
    /// - Parameter context: An additional info required to do the index calculations
    /// - Parameter removedIndex: Index which was removed
    /// - Returns a new selected index or nil if removed tab wasn't selected
    func autoSelectedIndexAfterTabRemove(
        context: IndexSelectionContext,
        removedIndex: Int
    ) async -> Int?
    /// Shows if we need to make the tab active/selected after creating it
    var makeTabActiveAfterAdding: Bool { get }
}
