//
//  Feature.swift
//  FeaturesFlagsKit
//
//  Created by Andrei Ermoshin on 2/22/20.
//  Copyright © 2020 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation

public protocol Feature {
    associatedtype Value

    static var source: FeatureSource.Type { get }
    static var defaultValue: Value { get }
    static var key: String { get }
    static var name: String { get }
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

/// For `syntatic sugar`
public struct ApplicationFeature<F: Feature> {
    public var defaultValue: F.Value {
        return F.defaultValue
    }

    public init() {}
}
