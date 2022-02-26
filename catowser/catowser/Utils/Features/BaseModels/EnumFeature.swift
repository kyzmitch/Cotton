//
//  EnumFeature.swift
//  catowser
//
//  Created by Andrey Ermoshin on 26.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation

/// Should be used for generic enum types, so, no static properties are allowed
/// Can't be a subset of a `BasicFeature` or `Feature` which have static properties
protocol EnumFeature {
    associatedtype EnumValue: CaseIterable & RawRepresentable
    associatedtype RawValue
    
    var defaultEnumValue: EnumValue { get }
    var defaultRawValue: RawValue { get }
    var source: FeatureSource.Type { get }
    var key: String { get }
    var name: String { get }
    var description: String { get }
}

extension EnumFeature {
    var source: FeatureSource.Type {
        return LocalFeatureSource.self
    }
    var name: String {
        return key
    }
    var description: String {
        return "\(name) feature"
    }
}

struct ApplicationEnumFeature<F: EnumFeature> {
    let feature: F
    
    var defaultValue: F.RawValue {
        return feature.defaultRawValue
    }
    
    var defaultEnumValue: F.EnumValue {
        return feature.defaultEnumValue
    }
}
