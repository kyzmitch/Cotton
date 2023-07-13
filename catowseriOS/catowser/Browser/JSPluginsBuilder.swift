//
//  JSPluginsBuilder.swift
//  catowser
//
//  Created by Andrei Ermoshin on 31/05/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import CottonPlugins
import CottonData

/**
 Creates the plugins by connecting them with observers (delegates).
 */
final class JSPluginsBuilder: JSPluginsSource {
    typealias Program = JSPluginsProgramImpl
    private var plugins: [any JavaScriptPlugin]

    init() {
        plugins = []
    }
    
    func setBase(_ baseDelegate: BasePluginContentDelegate) -> Self {
        if let basePlugin = BasePlugin(delegate: .base(baseDelegate)) {
            plugins.append(basePlugin)
        }
        return self
    }
    
    func setInstagram(_ instagramDelegate: InstagramContentDelegate) -> Self {
        if let igPlugin = InstagramContentPlugin(delegate: .instagram(instagramDelegate)) {
            plugins.append(igPlugin)
        }
        return self
    }
    
    var pluginsProgram: Program {
        JSPluginsProgramImpl(plugins)
    }
}
