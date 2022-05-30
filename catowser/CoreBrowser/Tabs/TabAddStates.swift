//
//  TabAddStates.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 5/30/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
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
