//
//  WebViewContext.swift
//  catowser
//
//  Created by Andrei Ermoshin on 8/4/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import JSPlugins

final class WebViewContext {
    /// Plugins are optional because there is possibility that js files are not present or plugins delegates are not set
    let pluginsBuilder: JSPluginsSource?
    
    init(_ plugins: JSPluginsSource?) {
        pluginsBuilder = plugins
    }
    
    var jsPlugins: JSPlugins? {
        pluginsBuilder?.jsPlugins
    }
}
