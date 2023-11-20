//
//  JSPluginsSource.swift
//
//  Created by Andrei Ermoshin on 31/05/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

public protocol JSPluginsSource: AnyObject {
    associatedtype Program: JSPluginsProgram
    var pluginsProgram: Program { get }
}
