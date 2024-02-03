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

/**
 An Object Structure (Program) from visitor desgin pattern. Could be a Composite
 */
public final class JSPluginsProgramImpl: JSPluginsProgram {
    public let plugins: [any JavaScriptPlugin]

    public init(_ plugins: [any JavaScriptPlugin]) {
        if plugins.count == 0 {
            print("Plugins program was initialized with 0 JS plugins")
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
        do {
            try plugins.forEach { try $0.accept(visitor, context, canInject) }
        } catch {
            print("\(#function) failed to load plugin: \(error.localizedDescription)")
        }
    }

    public func enable(on webView: JavaScriptEvaluateble, context: CottonBase.Host, jsEnabled: Bool) {
        guard !plugins.isEmpty else {
            return
        }
        plugins
            .filter { plugin in
                guard let pluginHostName = plugin.hostKeyword else {
                    return true
                }
                guard context.isSimilar(name: pluginHostName) else {
                    return false
                }
                return true
            }
            .compactMap { $0.scriptString(jsEnabled) }
            .forEach { webView.evaluate(jsScript: $0)}
    }
}

/**
 cannot use the == operator to compare 2 instances of existential type.
 https://swiftsenpai.com/swift/understanding-some-and-any/
 https://www.hackingwithswift.com/swift/5.7/unlock-existentials
 
 Also see "type erasure" techniques but without using any keyword:
 https://www.swiftbysundell.com/articles/different-flavors-of-type-erasure-in-swift/
 https://khawerkhaliq.com/blog/swift-protocols-equatable-part-two/
 */

public extension JSPluginsProgramImpl {
    static func == (lhs: JSPluginsProgramImpl, rhs: JSPluginsProgramImpl) -> Bool {
        guard lhs.plugins.count == rhs.plugins.count else {
            return false
        }
        
        var index = 0
        while index < lhs.plugins.count {
            let lv = lhs.plugins[index]
            let rv = rhs.plugins[index]
            if let blv = lv as? BasePlugin, let brv = rv as? BasePlugin, blv != brv {
                return false
            } else if let ilv = lv as? InstagramContentPlugin, let irv = rv as? InstagramContentPlugin, ilv != irv {
                return false
            }
            index += 1
        }
        return true

    }
}
