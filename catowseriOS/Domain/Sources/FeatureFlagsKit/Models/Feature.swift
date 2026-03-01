//
//  Feature.swift
//  FeaturesFlagsKit
//
//  Created by Andrei Ermoshin on 2/22/20.
//  Copyright © 2020 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation

/// Represents basic types (no enumeration types, see EnumFeature instead)
public protocol Feature {
    /// Feature value type
    associatedtype Value: Sendable

    /// Source where the value is stored
    static var source: FeatureSource.Type { get }
    /// Default value when it is not stored in the source yet
    static var defaultValue: Value { get }
    /// Key of feature to find/save in source
    static var key: String { get }
    /// Name of the feature
    static var name: String { get }
    /// Human readable description of the fuature
    static var description: String { get }
}

extension Feature {
    public static var name: String {
        return key
    }
    public static var description: String {
        return "\(name) feature"
    }
}

/// A wrapper type for "syntatic sugar"
public struct ApplicationFeature<F: Feature>: Sendable {
    public var defaultValue: F.Value {
        return F.defaultValue
    }

    public init() {}
}
