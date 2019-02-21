//
//  Box.swift
//  catowser
//
//  Created by Andrei Ermoshin on 2/21/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

/// Wrapper type to be able to have mutable associated values for enum cases
/// Source: https://stackoverflow.com/a/36765426
final class Box<T>: CustomDebugStringConvertible {
    var value: T
    var debugDescription: String { return "\(value)" }
    init(_ value: T) { self.value = value }
}
