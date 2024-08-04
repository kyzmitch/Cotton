//
//  JSPluginsBuilder.swift
//
//  Created by Andrei Ermoshin on 31/05/2019.
//  Copyright © 2019 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation
import WebKit

/**
 Creates the plugins by connecting them with observers (delegates).
 */
public final class JSPluginsBuilder: JSPluginsSource {
    public typealias Program = JSPluginsProgramImpl
    private var plugins: [(any JavaScriptPlugin, WKScriptMessageHandler)]

    public var jsProgram: Program {
        JSPluginsProgramImpl(plugins)
    }

    public init() {
        plugins = []
    }

    public func setBase(_ baseDelegate: BasePluginContentDelegate) -> Self {
        let basePlugin = BasePlugin()
        plugins.append((basePlugin, BaseJSHandler(baseDelegate)))
        return self
    }

    public func setInstagram(_ instagramDelegate: InstagramContentDelegate) -> Self {
        let igPlugin = InstagramContentPlugin()
        plugins.append((igPlugin, InstagramHandler(instagramDelegate)))
        return self
    }
}
