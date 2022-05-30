//
//  JSPluginsState.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 18/03/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import WebKit
import CoreHttpKit

public final class JSPluginsState {
    private let plugins: [JavaScriptPlugin]

    public init?(_ plugins: [JavaScriptPlugin]) {
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
                    let wkScript2 = try JSPluginFactory.shared.script(for: plugin,
                                                                      with: .atDocumentEnd,
                                                                      isMainFrameOnly: true)
                    userContentController.addUserScript(wkScript2)
                    
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

    public func enablePlugins(for webView: JavaScriptEvaluateble, with host: Host) {
        plugins
            .filter { !$0.hostKeyword.isEmpty || $0.messageHandlerName == .basePluginHName}
            .compactMap { $0.scriptString(host.rawString.contains($0.hostKeyword))}
            .forEach { webView.evaluate(jsScript: $0)}
    }
}
