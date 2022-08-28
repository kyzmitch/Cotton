//
//  JSPluginsSource.swift
//  catowser
//
//  Created by Andrei Ermoshin on 31/05/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import JSPlugins

protocol JSPluginsSource: AnyObject {
    var plugins: [JavaScriptPlugin] { get }
    var jsPlugins: JSPlugins? { get }
}
