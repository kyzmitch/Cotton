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
                if plugin is BasePlugin {
                    let wkScript1 = try JSPluginFactory.shared.script(for: plugin,
                                                                      with: .atDocumentStart,
                                                                      isMainFrameOnly: true)
                    let wkScript2 = try JSPluginFactory.shared.script(for: plugin,
                                                                      with: .atDocumentEnd,
                                                                      isMainFrameOnly: true)
                    let wkScript3 = try JSPluginFactory.shared.script(for: plugin,
                                                                      with: .atDocumentStart,
                                                                      isMainFrameOnly: false)
                    let wkScript4 = try JSPluginFactory.shared.script(for: plugin,
                                                                      with: .atDocumentEnd,
                                                                      isMainFrameOnly: false)
                    userContentController.addUserScript(wkScript1)
                    userContentController.addUserScript(wkScript2)
                    userContentController.addUserScript(wkScript3)
                    userContentController.addUserScript(wkScript4)
                    
                    userContentController.removeScriptMessageHandler(forName: plugin.messageHandlerName)
                    userContentController.add(plugin.handler, name: plugin.messageHandlerName)
                } else {
                    let wkScript = try JSPluginFactory.shared.script(for: plugin,
                                                                     with: .atDocumentStart,
                                                                     isMainFrameOnly: plugin.isMainFrameOnly)
                    userContentController.addUserScript(wkScript)
                    userContentController.removeScriptMessageHandler(forName: plugin.messageHandlerName)
                    userContentController.add(plugin.handler, name: plugin.messageHandlerName)
                }
            } catch {
                print("\(#function) failed to load plugin \(plugin.jsFileName)")
            }
        }
    }

    public func enablePlugins(for webView: JavaScriptEvaluateble, with host: String?) {
        guard let host = host else {
            return
        }
        for plugin in plugins where !plugin.hostKeyword.isEmpty {
            let jsScript = plugin.setEnableJsString(host.contains(plugin.hostKeyword))
            
            // https://github.com/WebKit/webkit/blob/39a299616172a4d4fe1f7aaf573b41020a1d7358/Source/WebKit/UIProcess/API/Cocoa/WKWebView.mm#L1009
            
            webView.evaluateJavaScript(jsScript, completionHandler: {(something, error) in
                if let err = error {
                    print("Error evaluating JavaScript: \(err)")
                } else if let thing = something {
                    print("Received value after evaluating: \(thing)")
                }
            })
        }
    }
}
