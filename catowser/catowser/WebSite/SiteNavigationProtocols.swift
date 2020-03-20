//
//  SiteNavigationProtocols.swift
//  catowser
//
//  Created by Andrei Ermoshin on 3/20/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import UIKit

protocol SiteNavigationDelegate: class {
    var canGoBack: Bool { get }
    var canGoForward: Bool { get }

    func goForward()
    func goBack()
    func reload()
}

protocol SiteExternalNavigationDelegate: class {
    func didStartProvisionalNavigation()
    func didOpenSiteWith(appName: String)
    func displayProgress(_ progress: Double)
    func showProgress(_ show: Bool)
    func updateTabPreview(_ screenshot: UIImage)
}

protocol SiteNavigationComponent: class {
    /// Use `nil` to tell that navigation actions should be disabled
    var siteNavigator: SiteNavigationDelegate? { get set }
    /// Reloads state of UI components
    func reloadNavigationElements(_ withSite: Bool, downloadsAvailable: Bool)
}
