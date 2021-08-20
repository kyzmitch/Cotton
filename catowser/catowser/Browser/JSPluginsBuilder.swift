//
//  JSPluginsBuilder.swift
//  catowser
//
//  Created by Andrei Ermoshin on 31/05/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import JSPlugins

final class JSPluginsBuilder {
    fileprivate let _plugins: [CottonJSPlugin]

    init?(baseDelegate: BasePluginContentDelegate,
          instagramDelegate: InstagramContentDelegate) {

        var array = [CottonJSPlugin]()
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

extension JSPluginsBuilder: PluginsBuilder {
    var plugins: [CottonJSPlugin] {
        return _plugins
    }
}
