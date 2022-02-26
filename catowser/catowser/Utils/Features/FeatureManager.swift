//
//  FeatureManager.swift
//  catowser
//
//  Created by Andrei Ermoshin on 2/22/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import CoreBrowser

final class FeatureManager {
    /// Shared instance has to be internal, to be able to divide code on extensions in separate files
    static let shared: FeatureManager = .init()
    /// fields have to be internal, to be able to move code to extensions in separate files
    let sources: [FeatureSource] = [LocalFeatureSource() /*, RemoteFeatureSource()*/]
    
    private init() {}
    
    static func boolValue<F: BasicFeature>(of feature: ApplicationFeature<F>) -> Bool where F.Value == Bool {
        guard let source = source(for: feature) else {
            return F.defaultValue
        }
        return source.currentValue(of: feature)
    }
    
    static func intValue<F: BasicFeature>(of feature: ApplicationFeature<F>) -> Int where F.Value == Int {
        guard let source = source(for: feature) else {
            return F.defaultValue
        }
        return source.currentValue(of: feature)
    }
}

// MARK: - special methods specific to features

extension FeatureManager {
    static func tabAddPositionValue() -> AddedTabPosition {
        let feature: ApplicationFeature = .tabAddPosition
        // swiftlint:disable:next force_unwrapping
        let defaultValue = AddedTabPosition(rawValue: feature.defaultValue)!
        guard let source = source(for: feature) else {
            return defaultValue
        }
        return AddedTabPosition(rawValue: source.currentValue(of: feature)) ?? defaultValue
    }
    
    static func tabDefaultContentValue() -> TabContentDefaultState {
        let feature: ApplicationFeature = .tabDefaultContent
        // swiftlint:disable:next force_unwrapping
        let defaultValue = TabContentDefaultState(rawValue: feature.defaultValue)!
        guard let source = source(for: feature) else {
            return defaultValue
        }
        return TabContentDefaultState(rawValue: source.currentValue(of: feature)) ?? defaultValue
    }
    
    static func appAsyncApiTypeValue() -> AsyncApiType {
        let feature: ApplicationFeature = .appDefaultAsyncApi
        // swiftlint:disable:next force_unwrapping
        let defaultValue = AsyncApiType(rawValue: feature.defaultValue)!
#if DEBUG
        guard let source = source(for: feature) else {
            return defaultValue
        }
        return AsyncApiType(rawValue: source.currentValue(of: feature)) ?? defaultValue
#else
        return defaultValue
#endif
    }
    
    static func webSearchAutoCompleteValue() -> WebAutoCompletionSource {
        let feature: ApplicationFeature = .webAutoCompletionSource
        // swiftlint:disable:next force_unwrapping
        let defaultValue = WebAutoCompletionSource(rawValue: feature.defaultValue)!
        guard let source = source(for: feature) else {
            return defaultValue
        }
        return WebAutoCompletionSource(rawValue: source.currentValue(of: feature)) ?? defaultValue
    }
}

// MARK: - Generic Enum features

extension FeatureManager {
    static func enumValue<F: CaseIterable>() -> F {
        
    }
}
