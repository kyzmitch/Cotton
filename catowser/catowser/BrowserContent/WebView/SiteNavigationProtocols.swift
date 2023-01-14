//
//  SiteNavigationProtocols.swift
//  catowser
//
//  Created by Andrei Ermoshin on 3/20/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import UIKit

protocol SiteExternalNavigationDelegate: AnyObject {
    func provisionalNavigationDidStart()
    func didSiteOpen(appName: String)
    func loadingProgressdDidChange(_ progress: Float)
    func didBackNavigationUpdate(to canGoBack: Bool)
    func didForwardNavigationUpdate(to canGoForward: Bool)
    func showLoadingProgress(_ show: Bool)
    func didTabPreviewChange(_ screenshot: UIImage)
    /// SwiftUI specific callback to notify that no need to initiate a re-use of web view anymore
    func webViewDidHandleReuseAction()
}

protocol SiteNavigationChangable: AnyObject {
    func changeBackButton(to canGoBack: Bool)
    func changeForwardButton(to canGoForward: Bool)
}

typealias FullSiteNavigationComponent = SiteNavigationComponent & SiteNavigationChangable
