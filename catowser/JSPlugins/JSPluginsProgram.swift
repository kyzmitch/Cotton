//
//  JSPluginsProgram.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 18/03/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import WebKit
import CoreHttpKit

/**
 An Object Structure (Program) from visitor desgin pattern. Could be a Composite
 */
public final class JSPluginsProgram {
    private let plugins: [JavaScriptPlugin]

    public init(_ plugins: [JavaScriptPlugin]) {
        if plugins.count == 0 {
            print("Plugins program was initialized with 0 JS plugins")
        }
        self.plugins = plugins
    }

    public func inject(to visitor: WKUserContentController, context: Host, canInject: Bool) {
        guard !plugins.isEmpty else {
            return
        }
        guard canInject else {
            visitor.removeAllUserScripts()
            return
        }
        visitor.removeAllUserScripts() // reset old state
        do {
            try plugins.forEach { try $0.accept(visitor, context, canInject) }
        } catch {
            print("\(#function) failed to load plugin: \(error.localizedDescription)")
        }
    }

    public func enable(on webView: JavaScriptEvaluateble, enable: Bool) {
        guard !plugins.isEmpty else {
            return
        }
        plugins.compactMap { $0.scriptString(enable) }.forEach { webView.evaluate(jsScript: $0)}
    }
}
