//
//  FeatureManager+SpecificEnums.swift
//  catowser
//
//  Created by Andrei Ermoshin on 2/28/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import CoreBrowser
import FeatureFlagsKit
import CottonTabs

// MARK: - generic GETTER method

extension FeatureManager.StateHolder {
    func enumValue<F: FullEnumTypeConstraints>(_ enumCase: F) async -> F?
    where F.RawValue == Int {
        let keyStr: String
        switch enumCase.defaultValue {
        case is WebAutoCompletionSource:
            keyStr = .autoCompletionKey
        case is AddedTabPosition:
            keyStr = .tabAddPositionKey
        case is CoreBrowser.Tab.ContentType:
            keyStr = .tabDefaultContentKey
        case is AsyncApiType:
            keyStr = .browserAsyncApiKey
        // For now it is unknown how to extend this func from another module,
        // wanted to move one option to ViewsBase module in Presentation
        // case is UIFrameworkType: keyStr = .uiFrameworkKey
        case is ObservingApiType:
            keyStr = .observingApiKey
        default:
            assertionFailure("Attempt to search for not supported enum feature type")
            return nil
        }
        return await enumValue(enumCase, keyStr)
    }
}

// MARK: - GETTER methods specific to Enum features

extension FeatureManager.StateHolder {
    /// Tab add position
    public func tabAddPositionValue() async -> AddedTabPosition {
        let feature: ApplicationEnumFeature = .tabAddPosition
        guard let source = source(for: feature) else {
            return feature.defaultEnumValue
        }
        return await source.currentEnumValue(of: feature)
    }

    /// Tab default content
    public func tabDefaultContentValue() async -> CoreBrowser.Tab.ContentType {
        let feature: ApplicationEnumFeature = .tabDefaultContent
        guard let source = source(for: feature) else {
            return feature.defaultEnumValue
        }
        return await source.currentEnumValue(of: feature)
    }

    /// Selected app async api
    public func appAsyncApiTypeValue() async -> AsyncApiType {
        let feature: ApplicationEnumFeature = .appDefaultAsyncApi
        #if DEBUG
        guard let source = source(for: feature) else {
            return feature.defaultEnumValue
        }
        return await source.currentEnumValue(of: feature)
        #else
        // We don't need to change this in Release builds
        return feature.defaultEnumValue
        #endif
    }

    /// Selected web search auto complete method
    public func webSearchAutoCompleteValue() async -> WebAutoCompletionSource {
        let feature: ApplicationEnumFeature = .webAutoCompletionSource
        guard let source = source(for: feature) else {
            return feature.defaultEnumValue
        }
        return await source.currentEnumValue(of: feature)
    }
    
    /// Selected observing API type
    public func observingApiTypeValue() async -> ObservingApiType {
        let feature: ApplicationEnumFeature = .observingApi
        guard let source = source(for: feature) else {
            return feature.defaultEnumValue
        }
        return await source.currentEnumValue(of: feature)
    }
}
