//
//  SiteNavigationProtocols.swift
//  catowser
//
//  Created by Andrei Ermoshin on 3/20/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import UIKit
import CoreBrowser

protocol SiteExternalNavigationDelegate: AnyObject {
    func provisionalNavigationDidStart()
    func didSiteOpen(appName: String)
    func loadingProgressdDidChange(_ progress: Float)
    func didBackNavigationUpdate(to canGoBack: Bool)
    func didForwardNavigationUpdate(to canGoForward: Bool)
    func showLoadingProgress(_ show: Bool)
    /// SwiftUI specific callback to notify that no need to initiate a re-use of web view anymore
    func webViewDidHandleReuseAction()
    /// SwiftUI specific to notify about the same view controller when web view changes.
    /// It will pass the existing web view controller because it is reused.
    /// It is the only way to reset interface when web view is re-created.
    func webViewDidReplace(_ interface: WebViewNavigatable?)
}

protocol SiteNavigationChangable: AnyObject {
    func changeBackButton(to canGoBack: Bool)
    func changeForwardButton(to canGoForward: Bool)
}

typealias FullSiteNavigationComponent = SiteNavigationComponent & SiteNavigationChangable
