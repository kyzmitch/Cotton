//
//  TabSelectionStrategy.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 05/03/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

public protocol IndexSelectionContext {
    var collectionLastIndex: Int { get }
    var currentlySelectedIndex: Int { get }
}

/**
 A Tab selection strategy (Compositor) defines the algorithms of tab selection in specific cases
 - when tab was removed and need to select another
 */
public protocol TabSelectionStrategy {
    func autoSelectedIndexAfterTabRemove(_ context: IndexSelectionContext, removedIndex: Int) -> Int
    var makeTabActiveAfterAdding: Bool { get }
}
