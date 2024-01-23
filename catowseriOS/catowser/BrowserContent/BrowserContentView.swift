//
//  BrowserContentView.swift
//  catowser
//
//  Created by Andrey Ermoshin on 14.12.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI
import CoreBrowser
import Combine
import FeaturesFlagsKit
import CottonPlugins

/// Dynamic content view (could be a webview, a top sites list or something else)
struct BrowserContentView: View {
    /// Plugins builder needed by web view model
    /// but the reference needs to be holded/created by another vm on upper level
    private let jsPluginsBuilder: any JSPluginsSource
    /// The main state of the browser content view
    private let contentType: Tab.ContentType
    /// Determines if the state is still loading to not show wrong content type (like default one).
    /// Depends on main view state, because this model's init is getting called unexpectedly.
    private let isLoading: Bool
    /// Tells if web view needs to be updated to avoid unnecessary updates.
    @Binding private var webViewNeedsUpdate: Bool
    /// Web view view model reference
    private let webViewModel: WebViewModelV2
    /// Selected swiftUI mode which is set at app start
    private let mode: SwiftUIMode
    ///
    @ObservedObject private var topSitesVM: TopSitesViewModel
    
    init(_ jsPluginsBuilder: any JSPluginsSource,
         _ siteNavigation: SiteExternalNavigationDelegate?,
         _ isLoading: Bool,
         _ contentType: Tab.ContentType,
         _ webViewNeedsUpdate: Binding<Bool>,
         _ mode: SwiftUIMode,
         _ topSitesVM: TopSitesViewModel) {
        self.isLoading = isLoading
        self.contentType = contentType
        _webViewNeedsUpdate = webViewNeedsUpdate
        webViewModel = WebViewModelV2(jsPluginsBuilder, siteNavigation)
        self.jsPluginsBuilder = jsPluginsBuilder
        self.mode = mode
        self.topSitesVM = topSitesVM
    }
    
    var body: some View {
        dynamicContentView
    }
    
    @ViewBuilder
    private var dynamicContentView: some View {
        if isLoading {
            Spacer()
        } else {
            switch contentType {
            case .blank:
                Spacer()
            case .topSites:
                TopSitesView(topSitesVM, mode)
            case .site(let site):
                WebView(webViewModel, site, webViewNeedsUpdate, mode)
            default:
                Spacer()
            }
        }
    }
}
