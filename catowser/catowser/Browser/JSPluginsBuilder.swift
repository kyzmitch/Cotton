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
    fileprivate let _plugins: [JavaScriptPlugin]

    init?(baseDelegate: BasePluginContentDelegate,
          instagramDelegate: InstagramContentDelegate) {

        var array = [JavaScriptPlugin]()
        guard let basePlugin = BasePlugin(delegate: .base(baseDelegate)) else {
            return nil
        }
        array.append(basePlugin)
        guard let igPlugin = InstagramContentPlugin(delegate: .instagram(instagramDelegate)) else {
            return nil
        }
        array.append(igPlugin)
        _plugins = array
    }
}

extension JSPluginsBuilder: JSPluginsSource {
    var plugins: [JavaScriptPlugin] {
        return _plugins
    }
    
    var jsPlugins: JSPlugins? {
        JSPlugins(_plugins)
    }
}
