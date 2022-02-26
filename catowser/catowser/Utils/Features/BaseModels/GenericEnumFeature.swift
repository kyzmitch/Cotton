//
//  GenericEnumFeature.swift
//  catowser
//
//  Created by Andrey Ermoshin on 26.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation

protocol EnumDefaultValueSupportable where Self: CaseIterable {
    var defaultValue: Self { get }
}

typealias FullEnumTypeConstraints = CaseIterable & RawRepresentable & EnumDefaultValueSupportable

struct GenericEnumFeature<E: FullEnumTypeConstraints>: EnumFeature where E.RawValue == Int {
    typealias RawValue = E.RawValue
    typealias EnumValue = E
    
    let wrappedEnumValue: EnumValue
    
    var defaultEnumValue: EnumValue {
        return wrappedEnumValue.defaultValue
    }
    
    var defaultRawValue: RawValue {
        return defaultEnumValue.rawValue
    }
    
    let key: String
    
    init(_ key: String) {
        // swiftlint:disable:next force_unwrapping
        wrappedEnumValue = E.allCases.first!
        self.key = key
    }
}
