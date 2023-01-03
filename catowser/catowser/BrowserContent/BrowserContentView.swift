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

/// Dynamic content view (could be a webview, a top sites list, etc.)
struct BrowserContentView: View {
    /// View model mainly used as a Tabs observer to know current tab's content type
    @ObservedObject var model: BrowserContentModel
    /// The main state of the browser content view
    @State private var state: Tab.ContentType
    /// Determines if the state is still loading to not show wrong content type (like default one)
    @State private var isLoading: Bool
    /// Web view view model
    private let webViewModel: WebViewModelV2
    
    init(model: BrowserContentModel) {
        self.model = model
        state = DefaultTabProvider.shared.contentState
        isLoading = true
        webViewModel = WebViewModelV2(model.jsPluginsBuilder)
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
                    TopSitesView(model: TopSitesModel())
                case .site(let site):
                    WebView(model: webViewModel, site: site)
                default:
                    Spacer()
                }
            }
        }
        .onReceive(model.$contentType.dropFirst(1)) { nextContentType in
            state = nextContentType
        }
        .onReceive(model.$loading.dropFirst(1)) { isStillLoading in
            isLoading = isStillLoading
        }
        .onReceive(webViewModel.$webViewInterface) { newWebViewInterface in
            // Just passing a reference to the upper model
            model.webViewInterface = newWebViewInterface
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
