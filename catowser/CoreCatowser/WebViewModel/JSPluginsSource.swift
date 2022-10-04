//
//  JSPluginsSource.swift
//  catowser
//
//  Created by Andrei Ermoshin on 31/05/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import JSPlugins

public protocol JSPluginsSource: AnyObject {
    var pluginsProgram: JSPluginsProgram { get }
}
