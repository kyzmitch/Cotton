//
//  SiteNavigationComponent.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/6/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation

protocol SiteNavigationComponent: AnyObject {
    /// Use `nil` to tell that navigation actions should be disabled
    var siteNavigator: WebViewNavigatable? { get set }
    /// Reloads state of UI components
    func reloadNavigationElements(_ withSite: Bool, downloadsAvailable: Bool)
}
