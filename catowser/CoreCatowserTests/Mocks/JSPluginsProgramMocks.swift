//
//  JSPluginsProgramMocks.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 10/9/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import JSPlugins
import WebKit
import CoreHttpKit

final class MockedJSPluginsProgram: JSPluginsProgram {
    let plugins: [any JavaScriptPlugin] = []
    
    static func == (lhs: MockedJSPluginsProgram, rhs: MockedJSPluginsProgram) -> Bool {
        // JFYI: Comparison could be better
        return lhs.plugins.count == rhs.plugins.count
    }
    
    func inject(to visitor: WKUserContentController, context: CoreHttpKit.Host, canInject: Bool) {
        
    }
    
    func enable(on webView: JSPlugins.JavaScriptEvaluateble, context: CoreHttpKit.Host, jsEnabled: Bool) {
        
    }
}