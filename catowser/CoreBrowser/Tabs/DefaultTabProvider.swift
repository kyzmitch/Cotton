//
//  DefaultTabProvider.swift
//  catowser
//
//  Created by Andrei Ermoshin on 01/02/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit

/// Describes how new tab is added to the list
public enum AddedTabPosition {
    case listEnd, afterSelected
}

public enum TabAddSpeed {
    case immediately
    case after(DispatchTimeInterval)
}

public final class DefaultTabProvider {
    public static let shared = DefaultTabProvider()

    private init() {}

    public var contentState: Tab.ContentType {
        // TODO: finish implementation and store it somewhere
        // maybe in UserDefaults plist
        // this method should be not async
        guard let site = Site(urlString: "https://www.instagram.com/uzbekspotter/") else {
            return .blank
        }
        return .site(site)
    }
    
    public var selected: Bool {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return true
        default:
            return true
        }
    }

    public var defaultPosition: AddedTabPosition {
        return .listEnd
    }

    public var addSpeed: TabAddSpeed {
        return .after(.milliseconds(300))
    }
}
