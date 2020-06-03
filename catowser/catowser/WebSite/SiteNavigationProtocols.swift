//
//  SiteNavigationProtocols.swift
//  catowser
//
//  Created by Andrei Ermoshin on 3/20/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import UIKit
import HttpKit
import CoreBrowser

// base protocol already based on `class`
// swiftlint:disable:next class_delegate_protocol
protocol SiteNavigationDelegate: SiteSettingsInterface {
    var canGoBack: Bool { get }
    var canGoForward: Bool { get }

    func goForward()
    func goBack()
    func reload()
    func openTabMenu(from sourceView: UIView, and sourceRect: CGRect)
    func reloadWithNewSettings(jsEnabled: Bool)
}

extension SiteNavigationDelegate {
    func update(jsEnabled: Bool) {
        reloadWithNewSettings(jsEnabled: jsEnabled)
    }
}

protocol SiteExternalNavigationDelegate: class {
    func didStartProvisionalNavigation()
    func didOpenSiteWith(appName: String)
    func displayProgress(_ progress: Double)
    func didUpdateBackNavigation(to canGoBack: Bool)
    func didUpdateForwardNavigation(to canGoForward: Bool)
    func showProgress(_ show: Bool)
    func updateTabPreview(_ screenshot: UIImage)
    func openTabMenu(from sourceView: UIView,
                     and sourceRect: CGRect,
                     for host: HttpKit.Host,
                     siteSettings: Site.Settings)
}

protocol SiteNavigationComponent: class {
    /// Use `nil` to tell that navigation actions should be disabled
    var siteNavigator: SiteNavigationDelegate? { get set }
    /// Reloads state of UI components
    func reloadNavigationElements(_ withSite: Bool, downloadsAvailable: Bool)
    func changeBackButton(to canGoBack: Bool)
    func changeForwardButton(to canGoForward: Bool)
}
