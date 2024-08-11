//
//  JSPluginsProgramImpl.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 18/03/2019.
//  Copyright © 2019 Cotton (former Catowser). All rights reserved.
//

import Foundation
import WebKit
import CottonBase

/// Host type is a model and can be sendable.
/// Can mark it as retroactive because it is from my CottonBase library.
extension CottonBase.Host: @unchecked @retroactive Sendable {}

/**
 An Object Structure (Program) from visitor desgin pattern. Could be a Composite
 */
@MainActor
public final class JSPluginsProgramImpl: JSPluginsProgram {
    public let plugins: [(any JavaScriptPlugin, WKScriptMessageHandler)]

    public init(
        _ plugins: [(any JavaScriptPlugin, WKScriptMessageHandler)]
    ) {
        guard !plugins.isEmpty else {
            fatalError("Plugins program was initialized with 0 JS plugins")
        }
        self.plugins = plugins
    }

    public func inject(to visitor: WKUserContentController, context: CottonBase.Host, canInject: Bool) {
        guard !plugins.isEmpty else {
            return
        }
        guard canInject else {
            visitor.removeAllUserScripts()
            return
        }
        visitor.removeAllUserScripts() // reset old state
        plugins.forEach { pair in
            do {
                try pair.0.accept(visitor, context, canInject, pair.1)
            } catch {
                print("\(#function) failed to load plugin: \(error.localizedDescription)")
            }
        }
    }

    public func enable(on webView: JavaScriptEvaluateble, context: CottonBase.Host, jsEnabled: Bool) {
        guard !plugins.isEmpty else {
            return
        }
        plugins
            .filter { pair in
                guard let pluginHostName = pair.0.hostKeyword else {
                    return true
                }
                guard context.isSimilar(name: pluginHostName) else {
                    return false
                }
                return true
            }
            .compactMap { $0.0.scriptString(jsEnabled) }
            .forEach { webView.evaluate(jsScript: $0)}
    }
}
