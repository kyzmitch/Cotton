//
//  WebViewModelV2.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/19/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI
import CoreHttpKit
import CoreBrowser

final class WebViewModelV2: ObservableObject {
    /// A reference to JavaScript plugins builder passed from root view
    let jsPluginsBuilder: any JSPluginsSource
    /// Web view interface which is set to some value only after initializing wkWebView
    @Published var webViewInterface: WebViewNavigatable?
    
    init(_ jsPluginsBuilder: any JSPluginsSource) {
        self.jsPluginsBuilder = jsPluginsBuilder
    }
}

extension WebViewModelV2: SiteExternalNavigationDelegate {
    func didBackNavigationUpdate(to canGoBack: Bool) {
    }
    
    func didForwardNavigationUpdate(to canGoForward: Bool) {
    }
    
    func provisionalNavigationDidStart() {
    }

    func didSiteOpen(appName: String) {
    }
    
    func loadingProgressdDidChange(_ progress: Float) {
    }
    
    func showLoadingProgress(_ show: Bool) {
    }
    
    func didTabPreviewChange(_ screenshot: UIImage) {
        try? TabsListManager.shared.setSelectedPreview(screenshot)
    }
}
