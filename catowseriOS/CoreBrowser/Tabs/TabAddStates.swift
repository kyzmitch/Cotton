//
//  TabAddStates.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 5/30/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation

/// Describes how new tab is added to the list.
/// Uses `Int` as raw value to be able to store it in settings.
public enum AddedTabPosition: Int, CaseIterable {
    case listEnd = 0
    case afterSelected = 1
}

public enum TabAddSpeed {
    case immediately
    case after(DispatchTimeInterval)
}
