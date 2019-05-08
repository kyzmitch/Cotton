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
        return .topSites
    }
    
    public var selected: Bool {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return true
        default:
            return false
        }
    }

    public var defaultPosition: AddedTabPosition {
        return .listEnd
    }

    public var addSpeed: TabAddSpeed {
        return .after(.milliseconds(300))
    }

    public var topSites: [Site] {
        var array: [Site] = []

        if let ig = Site(urlString: "https://www.instagram.com", customTitle: "Instagram") {
            array.append(ig)
        }
        if let opennet = Site(urlString: "https://opennet.ru", customTitle: "OpenNet") {
            array.append(opennet)
        }
        return array
    }
}
