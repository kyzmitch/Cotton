//
//  JSPluginsManager.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 18/03/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import WebKit

public final class JSPluginsManager {
    public static let shared = JSPluginsManager()

    private var activePlugins = Set<JSPluginName>()

    private init() {
        activePlugins.insert(.instagram)
        activePlugins.insert(.instagram)
    }

    public func visit(_ userContentController: WKUserContentController) {
        for pluginType in activePlugins {
            do {
                let wkScript = try JSPluginFactory.shared.script(for: pluginType)
                userContentController.addUserScript(wkScript)
                userContentController.add(pluginType.scriptHandler, name: pluginType.messageHandlerName)
            } catch {
                print("\(#function) failed to load plugin \(pluginType.rawValue)")
            }
        }
    }
}
