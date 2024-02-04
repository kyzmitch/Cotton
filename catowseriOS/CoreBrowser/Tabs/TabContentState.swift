//
//  TabContentState.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 5/30/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation

/// Twin type for `Tab.ContentType` to have `rawValue`
/// and use it for settings.
public enum TabContentDefaultState: Int, CaseIterable, CustomStringConvertible {
    case blank
    case homepage
    case favorites
    case topSites

    public var contentType: Tab.ContentType {
        switch self {
        case .blank:
            return .blank
        case .homepage:
            return .homepage
        case .favorites:
            return .favorites
        case .topSites:
            return .topSites
        }
    }

    public var description: String {
        let key: String

        switch self {
        case .blank:
            key = "txt_tab_content_blank"
        case .homepage:
            key = "txt_tab_content_homepage"
        case .favorites:
            key = "txt_tab_content_favorites"
        case .topSites:
            key = "txt_tab_content_top_sites"
        }
        return NSLocalizedString(key, comment: "")
    }
}
