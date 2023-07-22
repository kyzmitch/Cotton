//
//  TabSelectionStrategy.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 05/03/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import AutoMockable

public protocol IndexSelectionContext: AutoMockable {
    var collectionLastIndex: Int { get async }
    var currentlySelectedIndex: Int { get async }
}

public protocol TabSelectionStrategy: AutoMockable {
    /**
     A Tab selection strategy (Compositor) defines the algorithms of tab selection in specific cases
     - when tab was removed and need to select another
     */
    func autoSelectedIndexAfterTabRemove(_ context: IndexSelectionContext, removedIndex: Int) async -> Int
    var makeTabActiveAfterAdding: Bool { get }
}
