//
//  FeatureManager+EnumFeatures.swift
//  catowser
//
//  Created by Andrey Ermoshin on 26.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CoreBrowser

extension FeatureManager {
    static func setFeature<F: EnumFeature>(_ feature: ApplicationEnumFeature<F>, value: F.EnumValue?)
    where F.EnumValue.RawValue == Int {
        guard let source = source(for: feature) else {
            return
        }
        source.setEnumValue(of: feature, value: value)
    }
    
    static func source<F: EnumFeature>(for enumFeature: ApplicationEnumFeature<F>) -> EnumFeatureSource? {
        return shared.enumSources.first(where: { type(of: $0) == enumFeature.feature.source})
    }
}

// MARK: - generic GETTER method

extension FeatureManager {
    static func enumValue<F: FullEnumTypeConstraints>(_ enumCase: F) -> F? where F.RawValue == Int {
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
        default:
            assertionFailure("Attempt to search for not supported enum feature type")
            return nil
        }
        let enumFeature = GenericEnumFeature<F>(keyStr)
        let feature: ApplicationEnumFeature = .init(feature: enumFeature)
        guard let source = source(for: feature) else {
            return feature.defaultEnumValue
        }
        return source.currentEnumValue(of: feature)
    }
}

// MARK: - GETTER methods specific to Enum features

extension FeatureManager {
    static func tabAddPositionValue() -> AddedTabPosition {
        let feature: ApplicationEnumFeature = .tabAddPosition
        guard let source = source(for: feature) else {
            return feature.defaultEnumValue
        }
        return source.currentEnumValue(of: feature)
    }
    
    static func tabDefaultContentValue() -> TabContentDefaultState {
        let feature: ApplicationEnumFeature = .tabDefaultContent
        guard let source = source(for: feature) else {
            return feature.defaultEnumValue
        }
        return source.currentEnumValue(of: feature)
    }
    
    static func appAsyncApiTypeValue() -> AsyncApiType {
        let feature: ApplicationEnumFeature = .appDefaultAsyncApi
#if DEBUG
        guard let source = source(for: feature) else {
            return feature.defaultEnumValue
        }
        return source.currentEnumValue(of: feature)
#else
        return feature.defaultEnumValue
#endif
    }
    
    static func webSearchAutoCompleteValue() -> WebAutoCompletionSource {
        let feature: ApplicationEnumFeature = .webAutoCompletionSource
        guard let source = source(for: feature) else {
            return feature.defaultEnumValue
        }
        return source.currentEnumValue(of: feature)
    }
}
