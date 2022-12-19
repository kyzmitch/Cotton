//
//  WebViewSwiftUIModel.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/19/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI
import CoreHttpKit
import CoreBrowser

final class WebViewSwiftUIModel: ObservableObject {
    let site: Site
    let jsPluginsBuilder: any JSPluginsSource
    
    init(_ site: Site, _ jsPluginsBuilder: any JSPluginsSource) {
        self.site = site
        self.jsPluginsBuilder = jsPluginsBuilder
    }
}

extension WebViewSwiftUIModel: SiteExternalNavigationDelegate {
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
