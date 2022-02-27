//
//  Feature.swift
//  catowser
//
//  Created by Andrei Ermoshin on 2/22/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation

protocol Feature {
    associatedtype Value

    static var source: FeatureSource.Type { get }
    static var defaultValue: Value { get }
    static var key: String { get }
    static var name: String { get }
    static var description: String { get }
}

extension Feature {
    static var name: String {
        return key
    }
    static var description: String {
        return "\(name) feature"
    }
}

/// For `syntatic sugar`
struct ApplicationFeature<F: Feature> {
    var defaultValue: F.Value {
        return F.defaultValue
    }
}
