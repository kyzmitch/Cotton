//
//  FeatureManager+SpecificEnums.swift
//  catowser
//
//  Created by Andrei Ermoshin on 2/28/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import CoreBrowser
import FeaturesFlagsKit

// MARK: - generic GETTER method

extension FeatureManager.FManager {
    func enumValue<F: FullEnumTypeConstraints>(_ enumCase: F) -> F?
    where F.RawValue == Int {
        let keyStr: String
        switch enumCase.defaultValue {
        case is WebAutoCompletionSource:
            keyStr = .autoCompletionKey
        case is AddedTabPosition:
            keyStr = .tabAddPositionKey
        case is TabContentDefaultState:
            keyStr = .tabDefaultContentKey
        case is AsyncApiType:
            keyStr = .browserAsyncApiKey
        case is UIFrameworkType:
            keyStr = .uiFrameworkKey
        default:
            assertionFailure("Attempt to search for not supported enum feature type")
            return nil
        }
        return enumValue(enumCase, keyStr)
    }
}

// MARK: - GETTER methods specific to Enum features

extension FeatureManager.FManager {
    func tabAddPositionValue() -> AddedTabPosition {
        let feature: ApplicationEnumFeature = .tabAddPosition
        guard let source = source(for: feature) else {
            return feature.defaultEnumValue
        }
        return source.currentEnumValue(of: feature)
    }
    
    func tabDefaultContentValue() -> TabContentDefaultState {
        let feature: ApplicationEnumFeature = .tabDefaultContent
        guard let source = source(for: feature) else {
            return feature.defaultEnumValue
        }
        return source.currentEnumValue(of: feature)
    }
    
    func appAsyncApiTypeValue() -> AsyncApiType {
        let feature: ApplicationEnumFeature = .appDefaultAsyncApi
#if DEBUG
        guard let source = source(for: feature) else {
            return feature.defaultEnumValue
        }
        return source.currentEnumValue(of: feature)
#else
        // We don't need to change this in Release builds
        return feature.defaultEnumValue
#endif
    }
    
    func webSearchAutoCompleteValue() -> WebAutoCompletionSource {
        let feature: ApplicationEnumFeature = .webAutoCompletionSource
        guard let source = source(for: feature) else {
            return feature.defaultEnumValue
        }
        return source.currentEnumValue(of: feature)
    }
    
    func appUIFrameworkValue() -> UIFrameworkType {
        let feature: ApplicationEnumFeature = .appDefaultUIFramework
        guard let source = source(for: feature) else {
            return feature.defaultEnumValue
        }
        return source.currentEnumValue(of: feature)
    }
}
