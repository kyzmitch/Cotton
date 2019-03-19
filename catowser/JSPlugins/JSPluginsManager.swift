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

    private var activePlugins = [JSPluginName: WKScriptMessageHandler]()

    private init() {
        activePlugins[.instagram] = InstagramHandler()
    }

    public func visit(_ userContentController: WKUserContentController) {
        for (pluginType, handler) in activePlugins {
            do {
                let wkScript = try JSPluginFactory.shared.script(for: pluginType)
                userContentController.addUserScript(wkScript)
                userContentController.removeScriptMessageHandler(forName: pluginType.messageHandlerName)
                userContentController.add(handler, name: pluginType.messageHandlerName)
            } catch {
                print("\(#function) failed to load plugin \(pluginType.rawValue)")
            }
        }
    }
}
