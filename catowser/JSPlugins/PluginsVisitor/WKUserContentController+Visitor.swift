//
//  WKUserContentController+Visitor.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 6/4/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import WebKit
import CoreHttpKit

/// A Concrete Visitor which is in this case only one possible type from iOS SDK WebKit
extension WKUserContentController: JavaScriptPluginVisitor {
    public func canVisit(_ plugin: JavaScriptPlugin, _ host: Host, _ enabled: Bool) -> Bool {
        guard enabled else {
            return false
        }
        guard let pluginHostName = plugin.hostKeyword else {
            return true // should a base plugin which doesn't need to be enabled (ON by default)
        }
        guard host.isSimilar(name: pluginHostName) else {
            return false
        }
        return true
    }
    
    public func visit(_ plugin: JavaScriptPlugin) throws {
        if let base = plugin as? BasePlugin {
            try visit(basePlugin: base)
        } else if let instagram = plugin as? InstagramContentPlugin {
            try visit(instagramPlugin: instagram)
        }
    }
    
    private func visit(basePlugin: BasePlugin) throws {
        let wkScript = try JSPluginFactory.shared.script(for: basePlugin,
                                                        with: .atDocumentEnd,
                                                        isMainFrameOnly: true)
        addUserScript(wkScript)
        
        removeScriptMessageHandler(forName: basePlugin.messageHandlerName)
        add(basePlugin.handler, name: basePlugin.messageHandlerName)
    }
    
    private func visit(instagramPlugin: InstagramContentPlugin) throws {
        let wkScript = try JSPluginFactory.shared.script(for: instagramPlugin,
                                                         with: .atDocumentStart,
                                                         isMainFrameOnly: instagramPlugin.isMainFrameOnly)
        addUserScript(wkScript)
        removeScriptMessageHandler(forName: instagramPlugin.messageHandlerName)
        add(instagramPlugin.handler, name: instagramPlugin.messageHandlerName)
    }
}
