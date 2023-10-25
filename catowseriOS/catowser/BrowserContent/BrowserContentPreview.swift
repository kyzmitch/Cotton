//
//  BrowserContentPreview.swift
//  catowser
//
//  Created by Andrei Ermoshin on 1/13/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import CottonBase
import CottonPlugins
import SwiftUI
import CoreBrowser

#if DEBUG

// https://martinlasek.medium.com/swiftui-understanding-binding-8e20269a76bc

class DummyJSPluginsSource: JSPluginsSource {
    typealias Program = JSPluginsProgramImpl
    var pluginsProgram: Program {
        JSPluginsProgramImpl([])
    }
}

struct BrowserContentView_Previews: PreviewProvider {
    static var previews: some View {
        let source: DummyJSPluginsSource = .init()
        let isLoading = false
        let state: Binding<Tab.ContentType> = .init {
            let settings = Site.Settings(isPrivate: false,
                                         blockPopups: true,
                                         isJSEnabled: true,
                                         canLoadPlugins: false)
            // swiftlint:disable:next force_unwrapping
            let site = Site("https://opennet.ru", nil, settings)!
            return .site(site)
        } set: { _ in
            //
        }
        let needsUpdate: Binding<Bool> = .init {
            false
        } set: { _ in
            //
        }
        BrowserContentView(source, nil, isLoading, state, needsUpdate, .full)
    }
}

#endif
