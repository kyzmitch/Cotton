//
//  JSPlugins.swift
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
public final class JSPlugins {
    private let plugins: [JavaScriptPlugin]

    public init?(_ plugins: [JavaScriptPlugin]) {
        guard plugins.count != 0 else {
            assertionFailure("Can't initialize object with empty plugins list")
            return nil
        }
        self.plugins = plugins
    }

    public func accept(visitor: WKUserContentController, context: Host) {
        do {
            try plugins.forEach { try $0.accept(visitor, context, true) }
        } catch {
            print("\(#function) failed to load plugin: \(error.localizedDescription)")
        }
    }

    public func enable(on webView: JavaScriptEvaluateble, enable: Bool) {
        plugins
            .compactMap { $0.hostKeyword == nil ? nil : $0 }
            .compactMap { $0.scriptString(enable) }
            .forEach { webView.evaluate(jsScript: $0)}
    }
}
