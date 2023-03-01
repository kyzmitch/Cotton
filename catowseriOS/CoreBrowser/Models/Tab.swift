//
//  Tab.swift
//  catowser
//
//  Created by admin on 12/06/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import ReactiveSwift
import CottonCoreBaseKit

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
        public static func create(rawValue: Int16, site: Site? = nil) -> ContentType? {
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
                return .homepage
            case 3:
                return .favorites
            case 4:
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
        
        /// Shows if content type static or has dynamic dependecy like `Site`
        public var isStatic: Bool {
            if case .site = self {
                return false
            } else {
                return true
            }
        }
    }
}

extension Tab.ContentType: CaseIterable {
    public static var allCases: [Tab.ContentType] {
        [.blank, .homepage, .topSites, .favorites]
    }
}

extension Tab.ContentType: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .blank:
            return ".blank"
        case .site(let site):
            return ".site(url[\(site.urlInfo.platformURL.absoluteString)],ip[\(site.urlInfo.ipAddressString ?? "none")])"
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
            // For some reason Kotlin comparison doesn't work right for the identical objects
            // `return lSite == rSite`
            if lSite.urlInfo.platformURL != rSite.urlInfo.platformURL {
                return false
            }
            if lSite.searchSuggestion != rSite.searchSuggestion {
                return false
            }
            if lSite.userSpecifiedTitle != rSite.userSpecifiedTitle {
                return false
            }
            if lSite.settings != rSite.settings {
                return false
            }
            return true
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
    
    /// Not using `UIImage` to not depend on UIKit
    public var previewData: Data?

    public var searchBarContent: String {
        return contentType.searchBarContent
    }
    
    public var site: Site? {
        return contentType.site
    }
    
    public func isSelected(_ selectedId: UUID) -> Bool {
        return selectedId == id
    }
    
    public func getVisualState(_ selectedId: UUID) -> VisualState {
        return isSelected(selectedId) ? .selected : .deselected
    }

    /**
     Initializes an instance of `Tab` type.
     */
    public init(contentType: ContentType,
                idenifier: UUID = .init(),
                created: Date = .init()) {
        self.contentType = contentType
        addedTimestamp = created
        // set default value
        titleObserver.send(value: contentType.title)
        id = idenifier
    }

    public static let blank: Tab = Tab(contentType: .blank)
}

extension Tab: Equatable {
    public static func == (lhs: Tab, rhs: Tab) -> Bool {
        return lhs.id == rhs.id
    }
}

fileprivate extension String {
    static let defaultTitle = NSLocalizedString("ttl_tab_short_blank",
                                                comment: "Title for tab without any URL or search string")
    static let topSitesTitle = NSLocalizedString("ttl_tab_short_top_sites",
                                                 comment: "Title for tab with list of favorite sites")
}
