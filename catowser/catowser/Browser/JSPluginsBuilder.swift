//
//  JSPluginsBuilder.swift
//  catowser
//
//  Created by Andrei Ermoshin on 31/05/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import JSPlugins
import CoreCatowser

/**
 Creates the plugins by connecting them with observers (delegates).
 */
final class JSPluginsBuilder: JSPluginsSource {
    typealias Program = JSPluginsProgramImpl
    private let _plugins: [any JavaScriptPlugin]

    init(baseDelegate: BasePluginContentDelegate, instagramDelegate: InstagramContentDelegate) {

        var array = [any JavaScriptPlugin]()
        if let basePlugin = BasePlugin(delegate: .base(baseDelegate)) {
            array.append(basePlugin)
        }
        if let igPlugin = InstagramContentPlugin(delegate: .instagram(instagramDelegate)) {
            array.append(igPlugin)
        }
        
        _plugins = array
    }
    
    var pluginsProgram: Program {
        JSPluginsProgramImpl(_plugins)
    }
}
