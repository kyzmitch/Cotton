//
//  WebBrowserToolbarModel.swift
//  catowser
//
//  Created by Andrey Ermoshin on 03.01.2023.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI
import CoreBrowser

final class WebBrowserToolbarModel: ObservableObject {
    @Published var webViewInterface: WebViewNavigatable?
    /// Max value should be 1.0 because total is equals to that by default
    @Published var websiteLoadProgress: Double
    /// Tells if there is a web view content loading is in progress
    @Published var showProgress: Bool
    /// Tells that web view has handled re-use action and it is not needed anymore.
    /// Void type can be used, because only notification is needed.
    @Published var stopWebViewReuseAction: Void
    
    private var vcFactory: ViewControllerFactory {
        ViewsEnvironment.shared.vcFactory
    }
    
    private var siteNavigationDelegate: SiteNavigationChangable? {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return vcFactory.createdToolbaViewController as? SiteNavigationChangable
        } else {
            return vcFactory.createdDeviceSpecificSearchBarVC as? SiteNavigationChangable
        }
    }
    
    init() {
        webViewInterface = nil
        showProgress = false
        websiteLoadProgress = 0.0
        stopWebViewReuseAction = ()
    }
}

extension WebBrowserToolbarModel: WebViewCreationObserver {
    func webViewInterfaceDidChange(_ interface: WebViewNavigatable) {
        webViewInterface = interface
    }
}

extension WebBrowserToolbarModel: SiteExternalNavigationDelegate {
    func didBackNavigationUpdate(to canGoBack: Bool) {
        siteNavigationDelegate?.changeBackButton(to: canGoBack)
    }
    
    func didForwardNavigationUpdate(to canGoForward: Bool) {
        siteNavigationDelegate?.changeForwardButton(to: canGoForward)
    }
    
    func provisionalNavigationDidStart() {
    }

    func didSiteOpen(appName: String) {
    }
    
    func loadingProgressdDidChange(_ progress: Float) {
        websiteLoadProgress = Double(progress)
    }
    
    func showLoadingProgress(_ show: Bool) {
        showProgress = show
    }
    
    func didTabPreviewChange(_ screenshot: UIImage) {
        try? TabsListManager.shared.setSelectedPreview(screenshot)
    }
    
    func webViewDidHandleReuseAction() {
        stopWebViewReuseAction = ()
    }
}
