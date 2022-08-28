//
//  WebViewContext.swift
//  catowser
//
//  Created by Andrei Ermoshin on 8/4/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import JSPlugins

/// web view context should carry some data or dependencies which can't be stored as a state and always are present
final class WebViewContext {
    /// Plugins are optional because there is possibility that js files are not present or plugins delegates are not set
    let pluginsProgram: JSPluginsProgram
    
    init(_ pluginsSource: JSPluginsSource) {
        pluginsProgram = pluginsSource.pluginsProgram
    }
}
