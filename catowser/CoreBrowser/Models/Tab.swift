//
//  Tab.swift
//  catowser
//
//  Created by admin on 12/06/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import UIKit
import ReactiveSwift

public extension Tab {
    enum ContentType {
        case blank
        case site(Site)
        case homepage
        case favorites
        case topSites
        
        /// Needed for database representation
        public var rawValue: Int16 {
            switch self {
            case .blank:
                return 0
            case .site:
                return 1
            case .homepage:
                return 2
            case .favorites:
                return 3
            case .topSites:
                return 4
            }
        }
        
        /// Returns .blank for wrong parameters
        public static func create(rawValue: Int16, site: Site?) -> ContentType? {
            switch rawValue {
            case 0:
                return .blank
            case 1:
                guard let actualSite = site else {
                    print("No site instance for Tab.ContentType site \(rawValue)")
                    return nil
                }
                return .site(actualSite)
            case 2:
                return .favorites
            case 3:
                return .topSites
            default:
                print("Unexpected Tab.ContentType \(rawValue)")
                return nil
            }
        }

        var title: String {
            switch self {
            case .blank:
                return .defaultTitle
            case .site(let someSite):
                return someSite.title
            case .topSites:
                return .topSitesTitle
            default:
                return "Not implemented"
            }
        }

        var searchBarContent: String {
            switch self {
            case .site(let someSite):
                return someSite.searchBarContent
            default:
                return ""
            }
        }
        
        var site: Site? {
            guard case let .site(site) = self else {
                return nil
            }
            
            return site
        }
    }
}

extension Tab.ContentType: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .blank:
            return ".blank"
        case .site(let site):
            return ".site(\(site.host.rawValue))"
        case .homepage:
            return ".homepage"
        case .favorites:
            return ".favorites"
        case .topSites:
            return ".topSites"
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
    enum VisualState: Int16 {
        case selected, deselected
    }
}

/// View model for tab view which is a website representation for specific case
public struct Tab {
    // The id to be able to compare e.g. blank tabs and avoid switch to ref. type
    public let id: UUID
    // Actual website info stored only for one case
    public var contentType: ContentType
    // Usually only one tab should be in selected state
    public var visualState: VisualState
    /// Time when tab was added to provide sorting (including CoreData sorting)
    /// Do not support moving tabs on UI, because it won't work now with timestamps
    /// It will require to store indexes in a separate data structure
    public let addedTimestamp: Date
    /// Should be set to constants based on initial tab state (blank, top sites, etc.)
    /// `String` type probably should be replaced with Signal to be able to
    /// react on async title fetch from a real Site.
    public let (titleSignal, titleObserver) = Signal<String, Never>.pipe()

    public var title: String {
        return contentType.title
    }
    
    /// Since this is a reference type, we should make it private and use custom getter/setter to make a copy
    /// To keep this Tab type as a value type
    private var _preview: UIImage?
    
    /// Preview image of the site if content is .site
    public var preview: UIImage? {
        mutating get {
            // https://www.hackingwithswift.com/example-code/language/
            // how-to-safely-use-reference-types-inside-value-types-with-isknownuniquelyreferenced
            if !isKnownUniquelyReferenced(&_preview) {
                _preview = _preview?.copy() as? UIImage
            }
            return _preview
        }
        
        set {
            _preview = newValue
        }
    }

    public var searchBarContent: String {
        return contentType.searchBarContent
    }
    
    public var site: Site? {
        return contentType.site
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

    /**
     Initializes an instance of `Tab` type.
     */
    public init(contentType: ContentType,
                selected: Bool = true,
                idenifier: UUID = .init(),
                created: Date = .init()) {
        self.contentType = contentType
        addedTimestamp = created
        // set default value
        titleObserver.send(value: contentType.title)
        visualState = selected ? .selected : .deselected
        id = idenifier
    }

    public static let deselectedBlank: Tab = Tab(contentType: .blank, selected: false)
    public static let blank: Tab = Tab(contentType: .blank, selected: true)
}

extension Tab: Equatable {
    public static func == (lhs: Tab, rhs: Tab) -> Bool {
        return lhs.id == rhs.id
    }
}

fileprivate extension UIColor {
    static let superLightGray = UIColor(displayP3Red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
    static let normallyLightGray = UIColor(displayP3Red: 0.71, green: 0.71, blue: 0.71, alpha: 1.0)
    static let darkGrayText = UIColor(displayP3Red: 0.32, green: 0.32, blue: 0.32, alpha: 1.0)
    static let lightGrayText = UIColor(displayP3Red: 0.14, green: 0.14, blue: 0.14, alpha: 1.0)
}

fileprivate extension String {
    static let defaultTitle = NSLocalizedString("ttl_tab_short_blank",
                                                comment: "Title for tab without any URL or search string")
    static let topSitesTitle = NSLocalizedString("ttl_tab_short_top_sites",
                                                 comment: "Title for tab with list of favorite sites")
}
