//
//  JSPluginsSource.swift
//
//  Created by Andrei Ermoshin on 31/05/2019.
//  Copyright © 2019 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation

@MainActor
public protocol JSPluginsSource: AnyObject, Sendable {
    associatedtype Program: JSPluginsProgram
    var jsProgram: Program { get }
}
