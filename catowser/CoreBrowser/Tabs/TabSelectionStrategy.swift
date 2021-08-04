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

public protocol TabSelectionStrategy {
    func autoSelectedIndexAfterTabRemove(_ context: IndexSelectionContext, removedIndex: Int) -> Int
    func autoSelectedIndexAfterTabAdd(_ context: IndexSelectionContext, addedIndex: Int) -> Int
}

public struct NearbySelectionStrategy {}

extension NearbySelectionStrategy: TabSelectionStrategy {
    public func autoSelectedIndexAfterTabRemove(_ context: IndexSelectionContext, removedIndex: Int) -> Int {
        let value: Int

        if context.currentlySelectedIndex == removedIndex {
            // find if we're closing selected tab
            // select next - same behaviour is in Firefox for ios
            if removedIndex == context.collectionLastIndex {
                value = removedIndex - 1
            } else {
                // if it is not last index, then it is automatically will become next index as planned
                // index is the same, but tab content will be different, so, need to notify observers
                // re-settings same value will trigger observers notification
                value = context.currentlySelectedIndex
            }
        } else {
            if removedIndex < context.currentlySelectedIndex {
                value = context.currentlySelectedIndex - 1
            } else {
                // for opposite case it will stay the same
                value = context.currentlySelectedIndex
            }
        }

        return value
    }
    
    public func autoSelectedIndexAfterTabAdd(_ context: IndexSelectionContext, addedIndex: Int) -> Int {
        return addedIndex
    }
}
