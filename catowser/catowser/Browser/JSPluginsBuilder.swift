//
//  JSPluginsBuilder.swift
//  catowser
//
//  Created by Andrei Ermoshin on 31/05/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import JSPlugins

/**
 Creates the plugins by connecting them with observers (delegates).
 */
final class JSPluginsBuilder {
    private let _plugins: [JavaScriptPlugin]

    init(baseDelegate: BasePluginContentDelegate, instagramDelegate: InstagramContentDelegate) {

        var array = [JavaScriptPlugin]()
        if let basePlugin = BasePlugin(delegate: .base(baseDelegate)) {
            array.append(basePlugin)
        }
        if let igPlugin = InstagramContentPlugin(delegate: .instagram(instagramDelegate)) {
            array.append(igPlugin)
        }
        
        _plugins = array
    }
}

extension JSPluginsBuilder: JSPluginsSource {
    var pluginsProgram: JSPluginsProgram {
        JSPluginsProgram(_plugins)
    }
}
