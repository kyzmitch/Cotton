//
//  Box.swift
//  catowser
//
//  Created by Andrei Ermoshin on 2/21/19.
//  Copyright © 2019 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation

/// Wrapper type to be able to have mutable associated values for enum cases
/// Source: https://stackoverflow.com/a/36765426
public final class Box<T>: CustomDebugStringConvertible {
    public var value: T
    public var debugDescription: String { return "\(value)" }
    public init(_ value: T) { self.value = value }
}
