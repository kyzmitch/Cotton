//
//  WebView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/19/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI
import CoreHttpKit

/// web view specific to SwiftUI
struct WebView: View {
    @ObservedObject var model: WebViewModelV2
    /// Initial site with an url to load the web view
    private let site: Site
    /// A workaround to avoid unnecessary web view updates
    @Binding private var webViewNeedsUpdate: Bool
    
    init(_ model: WebViewModelV2,
         _ site: Site,
         _ webViewNeedsUpdate: Binding<Bool>) {
        self.model = model
        self.site = site
        _webViewNeedsUpdate = webViewNeedsUpdate
    }
    
    var body: some View {
        WebViewLegacyView(model, site, $webViewNeedsUpdate)
    }
}

/// SwiftUI wrapper around UIKit web view view controller
private struct WebViewLegacyView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    
    @ObservedObject private var model: WebViewModelV2
    /// Initial site with an url to load the web view
    private let site: Site
    /// A workaround to avoid unnecessary web view updates
    @Binding private var webViewNeedsUpdate: Bool
    /// Usual coordinator can't really be used for SwiftUI navigation
    /// but for the legacy view it has to be passed
    private let dummyArgument: WebContentCoordinator? = nil
    /// Convinience property to get a manager
    private var manager: WebViewsReuseManager {
        ViewsEnvironment.shared.reuseManager
    }
    
    init(_ model: WebViewModelV2,
         _ site: Site,
         _ webViewNeedsUpdate: Binding<Bool>) {
        self.model = model
        self.site = site
        _webViewNeedsUpdate = webViewNeedsUpdate
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        // Can't save web view interface here because it is immutable type.
        // Could be possible to fetch it from `WebViewsReuseManager` if it is
        // configured to use web views cache.
        let vc: (AnyViewController & WebViewNavigatable)? = try? manager.controllerFor(site,
                                                                                       model.jsPluginsBuilder,
                                                                                       model.siteNavigation,
                                                                                       dummyArgument)
        // swiftlint:disable:next force_unwrapping
        return vc!.viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        guard let reusableWebView = uiViewController as? WebViewReusable else {
            return
        }
        guard webViewNeedsUpdate else {
            return
        }
        // There is a warning:
        // `Publishing changes from within view updates is not allowed, this will cause undefined behavior.`
        // after replacing the UIKit's web view internally it calls body of `BrowserContentView`
        // and model is nil for some reason, but it works as expected
        // and allows to clear the web view navigation history
        // before reusing the existing web view
        if reusableWebView.resetTo(site) {
            model.stopViewUpdates = true
        }
    }
}
