//
//  LocalFeatureSource+BasicValues.swift
//  catowser
//
//  Created by Andrey Ermoshin on 26.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation

extension LocalFeatureSource: FeatureSource {
    public func currentValue<F: BasicFeature>(of feature: ApplicationFeature<F>) -> F.Value {
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
    
    public func setValue<F>(of feature: ApplicationFeature<F>, value: F.Value?) where F: BasicFeature {
        switch F.defaultValue {
        case is Bool:
            // swiftlint:disable:next force_cast
            let boolValue = value as! Bool
            LocalSettings.setGlobalBoolSetting(for: F.key.prefixed(), value: boolValue)
        case is Int:
            // swiftlint:disable:next force_cast
            let intValue = value as! Int
            LocalSettings.setGlobalIntSetting(for: F.key.prefixed(), value: intValue)
        default:
            assertionFailure("Value settings in Local source isn't implemented for other types")
        }
        
        let value = AnyFeature(feature)
        if #available(iOS 13.0, *) {
            self.featureSubject.send(value)
        }
        self.featureObserver.send(value: value)
    }
}

private extension String {
    func prefixed() -> String {
        return "CottonPrefix-Basic"+self
    }
}
