//
//  Tab.swift
//  catowser
//
//  Created by admin on 12/06/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

public extension Tab {
    enum ContentType {
        case blank
        case site(Site)
        case homepage
        case favorites
        case topSites

        var title: String {
            switch self {
            case .blank:
                return .defaultTitle
            case .site(let someSite):
                if let search = someSite.searchSuggestion {
                    return search
                } else {
                    return someSite.host
                }
            default:
                return "Not implemented"
            }
        }

        var searchBarContent: String {
            switch self {
            case .site(let someSite):
                return someSite.searchSuggestion ?? someSite.url.absoluteString
            default:
                return ""
            }
        }
    }
}


extension Tab.ContentType: Equatable {
    public static func == (lhs: Tab.ContentType, rhs: Tab.ContentType) -> Bool {
        switch (lhs, rhs) {
        case (.site(let lSite), .site(let rSite)):
            return lSite == rSite
        case (.blank, .blank):
            return true
        case (.homepage, .homepage):
            return true
        case (.favorites, .favorites):
            return true
        case (.topSites, .topSites):
            return true
        default:
            return false
        }
    }
}

public extension Tab {
    /// Replacement for `Bool` type to provide more clarity during usage on `view` layer.
    enum VisualState {
        case selected, deselected
    }
}

/// View model for tab view which is a website representation for specific case
public struct Tab {
    // The id to be able to compare e.g. blank tabs and avoid switch to ref. type
    let id: UUID
    // Actual website info stored only for one case
    public var contentType: ContentType
    // Usually only one tab should be in selected state
    public var visualState: VisualState
    /// Should be set to constants based on initial tab state (blank, top sites, etc.)
    /// `String` type probably should be replaced with Signal to be able to
    /// react on async title fetch from a real Site.
    public let (titleSignal, titleObserver) = Signal<String, NoError>.pipe()

    public var title: String {
        return contentType.title
    }

    public var searchBarContent: String {
        return contentType.searchBarContent
    }

    public var titleColor: UIColor {
        switch visualState {
        case .selected:
            return .lightGrayText
        case .deselected:
            return .darkGrayText
        }
    }

    public var backgroundColor: UIColor {
        switch visualState {
        case .selected:
            return .superLightGray
        case .deselected:
            return .normallyLightGray
        }
    }

    var tabCurvesColour: UIColor {
        switch visualState {
        case .selected:
            return .superLightGray
        case .deselected:
            return .normallyLightGray
        }
    }
    public let realBackgroundColour = UIColor.clear
    
    private(set) var faviconImage: UIImage?

    public init(contentType: ContentType, selected: Bool = true) {
        self.contentType = contentType
        // set default value
        titleObserver.send(value: contentType.title)
        visualState = selected ? .selected : .deselected
        id = UUID()
    }

    public static let deselectedBlank: Tab = Tab(contentType: .blank, selected: false)
    public static let blank: Tab = Tab(contentType: .blank, selected: true)
    public static var initial: Tab {
        return Tab(contentType: DefaultTabProvider.shared.contentState, selected: true)
    }
}

extension Tab: Equatable {
    public static func == (lhs: Tab, rhs: Tab) -> Bool {
        return lhs.id == rhs.id
    }
}

fileprivate extension UIColor {
    // TODO: check colours if some of them are not used
    static let superLightGray = UIColor(displayP3Red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
    static let normallyLightGray = UIColor(displayP3Red: 0.71, green: 0.71, blue: 0.71, alpha: 1.0)
    static let darkGrayText = UIColor(displayP3Red: 0.32, green: 0.32, blue: 0.32, alpha: 1.0)
    static let lightGrayText = UIColor(displayP3Red: 0.14, green: 0.14, blue: 0.14, alpha: 1.0)
}

fileprivate extension String {
    static let defaultTitle = NSLocalizedString("ttl_tab_short_blank", comment: "Title for tab without any URL or search string")
    static let favoriteSitesTitle = NSLocalizedString("ttl_tab_short_favorites", comment: "Title for tab with list of favorite sites")
}
