//
//  JSPluginsBuilder.swift
//
//  Created by Andrei Ermoshin on 31/05/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

/**
 Creates the plugins by connecting them with observers (delegates).
 */
public final class JSPluginsBuilder: JSPluginsSource {
    public typealias Program = JSPluginsProgramImpl
    private var plugins: [any JavaScriptPlugin]

    public var jsProgram: Program {
        JSPluginsProgramImpl(plugins)
    }
    
    public init() {
        plugins = []
    }
    
    public func setBase(_ baseDelegate: BasePluginContentDelegate) -> Self {
        if let basePlugin = BasePlugin(delegate: .base(baseDelegate)) {
            plugins.append(basePlugin)
        }
        return self
    }
    
    public func setInstagram(_ instagramDelegate: InstagramContentDelegate) -> Self {
        if let igPlugin = InstagramContentPlugin(delegate: .instagram(instagramDelegate)) {
            plugins.append(igPlugin)
        }
        return self
    }
}
