//
//  SiteNavigationProtocols.swift
//  catowser
//
//  Created by Andrei Ermoshin on 3/20/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import UIKit
import CoreHttpKit
import CoreBrowser

protocol SiteNavigationDelegate: AnyObject {
    var canGoBack: Bool { get }
    var canGoForward: Bool { get }

    func goForward()
    func goBack()
    func reload()
    func enableJavaScript(_ enabled: Bool)
}

protocol SiteExternalNavigationDelegate: AnyObject {
    func provisionalNavigationDidStart()
    func didSiteOpen(appName: String)
    func loadingProgressdDidChange(_ progress: Float)
    func didBackNavigationUpdate(to canGoBack: Bool)
    func didForwardNavigationUpdate(to canGoForward: Bool)
    func showLoadingProgress(_ show: Bool)
    func didTabPreviewChange(_ screenshot: UIImage)
}

protocol SiteNavigationComponent: AnyObject {
    /// Use `nil` to tell that navigation actions should be disabled
    var siteNavigator: SiteNavigationDelegate? { get set }
    /// Reloads state of UI components
    func reloadNavigationElements(_ withSite: Bool, downloadsAvailable: Bool)
}

protocol SiteNavigationChangable: AnyObject {
    func changeBackButton(to canGoBack: Bool)
    func changeForwardButton(to canGoForward: Bool)
}

typealias FullSiteNavigationComponent = SiteNavigationComponent & SiteNavigationChangable
