//
//  JSPluginsProgramMocks.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 10/9/22.
//  Copyright © 2022 Cotton (former Catowser). All rights reserved.
//

import CottonPlugins
import WebKit
import CottonBase

@MainActor
final class MockedJSPluginsProgram: JSPluginsProgram {
    var plugins: [CottonPlugins.HandlablePlugin] = []

    static func == (
        lhs: MockedJSPluginsProgram,
        rhs: MockedJSPluginsProgram
    ) -> Bool {
        // JFYI: Comparison could be better
        return lhs.plugins.count == rhs.plugins.count
    }

    func inject(
        to visitor: WKUserContentController,
        context: CottonBase.Host,
        canInject: Bool
    ) {

    }

    func enable(
        on webView: JavaScriptEvaluateble,
        context: CottonBase.Host,
        jsEnabled: Bool
    ) {

    }
}

@MainActor
final class MockedJSPluginsSource: JSPluginsSource {
    typealias Program = MockedJSPluginsProgram
    let jsProgram: MockedJSPluginsProgram

    init() {
        jsProgram = MockedJSPluginsProgram()
    }
}
