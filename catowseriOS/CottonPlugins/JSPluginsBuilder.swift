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
    private var plugins: [HandlablePlugin]

    public var jsProgram: Program {
        JSPluginsProgramImpl(plugins)
    }

    public init() {
        plugins = []
    }

    public func setBase(_ baseDelegate: BasePluginContentDelegate) -> Self {
        let basePlugin = BasePlugin()
        let value = HandlablePlugin(
            plugin: basePlugin,
            handler: BaseJSHandler(baseDelegate)
        )
        plugins.append(value)
        return self
    }

    public func setInstagram(_ instagramDelegate: InstagramContentDelegate) -> Self {
        let igPlugin = InstagramContentPlugin()
        let value = HandlablePlugin(
            plugin: igPlugin,
            handler: InstagramHandler(instagramDelegate)
        )
        plugins.append(value)
        return self
    }
}
