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
 An Object Structure (Program) from visitor desgin pattern. Could be a Composite.
 Should be main actor because it stores wk handlers which are marked as
 main actors in the sdk.
 */
@MainActor
public final class JSPluginsProgramImpl: JSPluginsProgram, @preconcurrency Equatable {
    public let plugins: [HandlablePlugin]

    public init(
        _ plugins: [HandlablePlugin]
    ) {
        guard !plugins.isEmpty else {
            fatalError("Plugins program was initialized with 0 JS plugins")
        }
        self.plugins = plugins
    }

    public func inject(
        to visitor: WKUserContentController,
        context: CottonBase.Host,
        canInject: Bool
    ) {
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
                try pair.plugin.accept(visitor, context, canInject, pair.handler)
            } catch {
                print("\(#function) failed to load plugin: \(error.localizedDescription)")
            }
        }
    }

    public func enable(
        on webView: JavaScriptEvaluateble,
        context: CottonBase.Host,
        jsEnabled: Bool
    ) {
        guard !plugins.isEmpty else {
            return
        }
        plugins
            .filter { pair in
                guard let pluginHostName = pair.plugin.hostKeyword else {
                    return true
                }
                guard context.isSimilar(name: pluginHostName) else {
                    return false
                }
                return true
            }
            .compactMap { $0.plugin.scriptString(jsEnabled) }
            .forEach { webView.evaluate(jsScript: $0)}
    }
}

extension JSPluginsProgramImpl {
    public static func == (lhs: JSPluginsProgramImpl, rhs: JSPluginsProgramImpl) -> Bool {
        guard lhs.plugins.count == rhs.plugins.count else {
            return false
        }
        var index = 0
        while index < lhs.plugins.count {
            let lPair = lhs.plugins[index]
            let rPair = rhs.plugins[index]
            #warning("TODO: rework or remove, cause this code is hard to scale")
            if let lInst = lPair.plugin as? InstagramContentPlugin, let rInst = rPair.plugin as? InstagramContentPlugin, lInst == rInst {
                index += 1
                continue
            } else if let lInst = lPair.plugin as? BasePlugin, let rInst = rPair.plugin as? BasePlugin, lInst == rInst {
                index += 1
                continue
            } else {
                return false
            }
        }
        return true
    }
}
