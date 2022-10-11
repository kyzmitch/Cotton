//
//  TabSelectionStrategy.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 05/03/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

// sourcery: AutoMockable
public protocol IndexSelectionContext {
    var collectionLastIndex: Int { get }
    var currentlySelectedIndex: Int { get }
}

// sourcery: AutoMockable
public protocol TabSelectionStrategy {
    /**
     A Tab selection strategy (Compositor) defines the algorithms of tab selection in specific cases
     - when tab was removed and need to select another
     */
    func autoSelectedIndexAfterTabRemove(_ context: IndexSelectionContext, removedIndex: Int) -> Int
    var makeTabActiveAfterAdding: Bool { get }
}
