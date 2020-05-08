//
//  LocalFeatureSource.swift
//  catowser
//
//  Created by Andrei Ermoshin on 2/22/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation

// FeatureSource that uses UserDefaults
final class LocalFeatureSource: FeatureSource {
    init() {}
    
    func currentValue<F: BasicFeature>(of feature: ApplicationFeature<F>) -> F.Value {
        switch F.defaultValue {
        case is String:
            guard let result = LocalSettings.getGlobalStringSetting(for: F.key.prefixed()) else {
                return F.defaultValue
            }
            return result as? F.Value ?? F.defaultValue
        case is Int:
            let savedNumber = LocalSettings.getGlobalIntSetting(for: F.key.prefixed())
            return savedNumber as? F.Value ?? F.defaultValue
        case is Bool:
            guard let globalSetting = LocalSettings.getGlobalBoolSetting(for: F.key.prefixed()) else {
                return F.defaultValue
            }
            return globalSetting as? F.Value ?? F.defaultValue
        default:
            // Shouldn't be here...
            let errString = "Trying to save invalid state for feature setting"
            print(errString)
            assertionFailure(errString)
            return F.defaultValue
        }
    }
    
    func setValue<F>(of feature: ApplicationFeature<F>, value: F.Value?) where F : BasicFeature {
        switch F.defaultValue {
        case is Bool:
            // TODO: Make implementation based on generics to not have conversions
            guard let boolValue = value as? Bool else {
                return
            }
            LocalSettings.setGlobalBoolSetting(for: F.key.prefixed(), value: boolValue)
        default:
            assertionFailure("Not implemented")
        }
    }
}

private extension String {
    func prefixed() -> String {
        return "CottonPrefix-"+self
    }
}
