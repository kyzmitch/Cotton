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
    }
    
    func showLoadingProgress(_ show: Bool) {
    }
    
    func didTabPreviewChange(_ screenshot: UIImage) {
        try? TabsListManager.shared.setSelectedPreview(screenshot)
    }
}
