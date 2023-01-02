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

    @State private var state: Tab.ContentType = DefaultTabProvider.shared.contentState
    
    var body: some View {
        VStack {
            switch state {
            case .blank:
                EmptyView()
                    .background(.white)
            case .topSites:
                TopSitesView(model: TopSitesModel())
            case .site(let site):
                WebViewV2(model: WebViewSwiftUIModel(site, model.jsPluginsBuilder))
            default:
                EmptyView()
            }
        }
        .onReceive(model.$contentType) { nextContentType in
            state = nextContentType
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
