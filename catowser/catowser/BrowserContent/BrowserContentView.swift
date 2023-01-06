//
//  BrowserContentView.swift
//  catowser
//
//  Created by Andrey Ermoshin on 14.12.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI
import CoreBrowser
import JSPlugins
import Combine

/// Dynamic content view (could be a webview, a top sites list or something else)
struct BrowserContentView: View {
    /// View model mainly used as a Tabs observer to know current tab's content type
    private var model: BrowserContentModel
    /// The main state of the browser content view
    @Binding private var state: Tab.ContentType
    /// Determines if the state is still loading to not show wrong content type (like default one).
    /// Depends on main view state, because this model's init is getting called unexpectedly.
    @Binding private var isLoading: Bool
    /// Tells if web view needs to be updated to avoid unnecessary updates.
    @Binding private var webViewNeedsUpdate: Bool
    /// Web view view model reference
    private let webViewModel: WebViewModelV2
    /// Top sites model reference
    private let topSitesModel: TopSitesModel
    /// Improved web view content publisher, attempt to fix `removeDuplicates` part
    /// because it could be re-created during view body update.
    private let contentType: AnyPublisher<Tab.ContentType, Never>
    
    init(_ model: BrowserContentModel,
         _ siteNavigation: SiteExternalNavigationDelegate?,
         _ isLoading: Binding<Bool>,
         _ state: Binding<Tab.ContentType>,
         _ webViewNeedsUpdate: Binding<Bool>) {
        _isLoading = isLoading
        _state = state
        _webViewNeedsUpdate = webViewNeedsUpdate
        webViewModel = WebViewModelV2(model.jsPluginsBuilder, siteNavigation)
        topSitesModel = TopSitesModel()
        // drops first value because it is default one
        // which it seems like must be initialized anyway
        // but don't need to be used
        contentType = model
            .$contentType
            .dropFirst(1)
            .removeDuplicates()
            .eraseToAnyPublisher()
        self.model = model
    }
    
    var body: some View {
        VStack {
            if isLoading {
                Spacer()
            } else {
                switch state {
                case .blank:
                    Spacer()
                case .topSites:
                    TopSitesView(topSitesModel)
                case .site(let site):
                    WebView(webViewModel, site, $webViewNeedsUpdate)
                default:
                    Spacer()
                }
            }
        }
        .onReceive(contentType) { value in
            if state != value {
                // using additional check because `removeDuplicates` didn't work?
                state = value
            }
        }
        .onReceive(model.$loading.dropFirst(1)) { value in
            isLoading = value
        }
    }
}

#if DEBUG

// https://martinlasek.medium.com/swiftui-understanding-binding-8e20269a76bc

class DummyJSPluginsSource: JSPluginsSource {
    typealias Program = JSPluginsProgramImpl
    var pluginsProgram: Program {
        JSPluginsProgramImpl([])
    }
}

struct BrowserContentView_Previews: PreviewProvider {
    static let model: BrowserContentModel = {
        let source: DummyJSPluginsSource = .init()
        return .init(source)
    }()
    
    static var previews: some View {
        EmptyView()
    }
}

#endif
