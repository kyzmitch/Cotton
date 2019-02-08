//
//  DefaultTabProvider.swift
//  catowser
//
//  Created by Andrei Ermoshin on 01/02/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit

/// Describes how new tab is added to the list
enum AddedTabPosition {
    case listEnd, afterSelected
}

enum TabAddSpeed {
    case immediately
    case after(DispatchTimeInterval)
}

final class DefaultTabProvider {
    static let shared = DefaultTabProvider()

    private init() {}

    var contentState: Tab.ContentType {
        // TODO: finish implementation and store it somewhere
        // maybe in UserDefaults plist
        // this method should be not async
        return .blank
    }
    
    var selected: Bool {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return true
        default:
            return true
        }
    }

    var defaultPosition: AddedTabPosition {
        return .listEnd
    }

    var addSpeed: TabAddSpeed {
        return .after(.milliseconds(300))
    }
}
