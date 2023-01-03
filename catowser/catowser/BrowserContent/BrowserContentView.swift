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
    @ObservedObject var model: BrowserContentModel

    @State private var state: Tab.ContentType
    @State private var isLoading: Bool
    private let webViewModel: WebViewSwiftUIModel
    
    init(model: BrowserContentModel) {
        self.model = model
        state = DefaultTabProvider.shared.contentState
        isLoading = true
        webViewModel = WebViewSwiftUIModel(model.jsPluginsBuilder)
    }
    
    var body: some View {
        VStack {
            if isLoading {
                Spacer()
                    .background(.black)
                    .progressViewStyle(.circular)
            } else {
                switch state {
                case .blank:
                    Spacer()
                        .background(.black)
                case .topSites:
                    TopSitesView(model: TopSitesModel())
                case .site(let site):
                    WebView(model: webViewModel, site: site)
                default:
                    Spacer()
                        .background(.black)
                }
            }
        }
        .onReceive(model.$contentType.dropFirst(1)) { nextContentType in
            state = nextContentType
        }
        .onReceive(model.$loading.dropFirst(1)) { nextLoadingState in
            isLoading = nextLoadingState
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
