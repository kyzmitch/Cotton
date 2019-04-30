//
//  WebViewJSPluginsFacade.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 18/03/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import WebKit

public protocol JavaScriptEvaluateble: class {
    func evaluateJavaScript(_ javaScriptString: String, completionHandler: ((Any?, Error?) -> Void)?)
}

public final class WebViewJSPluginsFacade {
    private let plugins: [CottonJSPlugin]

    public init?(_ plugins: [CottonJSPlugin]) {
        guard plugins.count != 0 else {
            assertionFailure("Can't initialize object with empty plugins list")
            return nil
        }
        self.plugins = plugins
    }

    public func visit(_ userContentController: WKUserContentController) {
        for plugin in plugins {
            do {
                let wkScript = try JSPluginFactory.shared.script(for: plugin)
                userContentController.addUserScript(wkScript)
                userContentController.removeScriptMessageHandler(forName: plugin.messageHandlerName)
                userContentController.add(plugin.handler, name: plugin.messageHandlerName)
            } catch {
                print("\(#function) failed to load plugin \(plugin.jsFileName)")
            }
        }
    }

    public func enablePlugins(for webView: JavaScriptEvaluateble, with host: String) {
        for plugin in plugins where !plugin.hostKeyword.isEmpty {
            let jsScript = plugin.setEnableJsString(host.contains(plugin.hostKeyword))
            webView.evaluateJavaScript(jsScript, completionHandler: {(something, error) in
                if let err = error {
                    print("Failed to use plugin enabled property: \(err)")
                } else if let thing = something {
                    print("Received response: \(thing)")
                }
            })
        }
    }
}
