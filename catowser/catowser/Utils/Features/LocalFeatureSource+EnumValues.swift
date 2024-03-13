//
//  LocalFeatureSource+EnumValues.swift
//  catowser
//
//  Created by Andrey Ermoshin on 26.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation

extension LocalFeatureSource: EnumFeatureSource {
    func currentEnumValue<F: EnumFeature>(of feature: ApplicationEnumFeature<F>) -> F.EnumValue
    where F.EnumValue.RawValue == Int {
        guard let result = LocalSettings.getGlobalIntSetting(for: feature.feature.key.prefixed()) else {
            return feature.defaultEnumValue
        }
        return F.EnumValue(rawValue: result) ?? feature.defaultEnumValue
    }
    
    func setEnumValue<F: EnumFeature>(of feature: ApplicationEnumFeature<F>, value: F.EnumValue?)
    where F.EnumValue.RawValue == Int {
        guard let intValue = value?.rawValue else {
            return
        }
        LocalSettings.setGlobalIntSetting(for: feature.feature.key.prefixed(), value: intValue)
    }
}

private extension String {
    func prefixed() -> String {
        return "CottonPrefix-Enum"+self
    }
}
