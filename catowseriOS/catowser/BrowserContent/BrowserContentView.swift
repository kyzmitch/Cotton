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

/// Dynamic content view (could be a webview, a top sites list or something else)
struct BrowserContentView: View {
    /// Plugins builder needed by web view model but the reference needs to be holded/created by another vm on upper level
    private let jsPluginsBuilder: any JSPluginsSource
    /// The main state of the browser content view
    @Binding private var contentType: Tab.ContentType
    /// Determines if the state is still loading to not show wrong content type (like default one).
    /// Depends on main view state, because this model's init is getting called unexpectedly.
    @Binding private var isLoading: Bool
    /// Tells if web view needs to be updated to avoid unnecessary updates.
    @Binding private var webViewNeedsUpdate: Bool
    /// Web view view model reference
    private let webViewModel: WebViewModelV2
    /// Top sites model reference
    private let topSitesModel: TopSitesModel
    /// Selected swiftUI mode which is set at app start
    private let mode: SwiftUIMode
    
    init(_ jsPluginsBuilder: any JSPluginsSource,
         _ siteNavigation: SiteExternalNavigationDelegate?,
         _ isLoading: Binding<Bool>,
         _ contentType: Binding<Tab.ContentType>,
         _ webViewNeedsUpdate: Binding<Bool>,
         _ mode: SwiftUIMode) {
        _isLoading = isLoading
        _contentType = contentType
        _webViewNeedsUpdate = webViewNeedsUpdate
        webViewModel = WebViewModelV2(jsPluginsBuilder, siteNavigation)
        topSitesModel = TopSitesModel()
        self.jsPluginsBuilder = jsPluginsBuilder
        self.mode = mode
    }
    
    var body: some View {
        VStack {
            if isLoading {
                Spacer()
            } else {
                switch contentType {
                case .blank:
                    Spacer()
                case .topSites:
                    TopSitesView(topSitesModel, mode)
                case .site(let site):
                    WebView(webViewModel, site, $webViewNeedsUpdate, mode)
                default:
                    Spacer()
                }
            }
        }
    }
}
