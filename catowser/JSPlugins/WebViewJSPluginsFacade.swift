//
//  WebViewJSPluginsFacade.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 18/03/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import WebKit

public final class WebViewJSPluginsFacade {
    private var activePlugins: [JSPluginName: WKScriptMessageHandler]

    public init?(_ pluginsDelegates: [PluginHandlerDelegate]) {
        guard pluginsDelegates.count != 0 else {
            assertionFailure("Can't initialize object with empty plugins list")
            return nil
        }
        activePlugins = [JSPluginName: WKScriptMessageHandler]()
        for pluginDelegate in pluginsDelegates {

        }
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
