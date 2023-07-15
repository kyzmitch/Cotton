//
//  FeatureManager+EnumFeatures.swift
//  FeaturesFlagsKit
//
//  Created by Andrey Ermoshin on 26.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CoreBrowser

extension FeatureManager.FManager {
    public func setFeature<F: EnumFeature>(_ feature: ApplicationEnumFeature<F>, value: F.EnumValue?)
    where F.EnumValue.RawValue == Int {
        guard let source = source(for: feature) else {
            return
        }
        source.setEnumValue(of: feature, value: value)
    }
    
    public func source<F: EnumFeature>(for enumFeature: ApplicationEnumFeature<F>) -> EnumFeatureSource? {
        return enumSources.first(where: { type(of: $0) == enumFeature.feature.source})
    }
    
    public func enumValue<F: FullEnumTypeConstraints>(_ enumCase: F, _ key: String) -> F?
    where F.RawValue == Int {
        let enumFeature = GenericEnumFeature<F>(key)
        let feature: ApplicationEnumFeature = .init(feature: enumFeature)
        guard let source = source(for: feature) else {
            return feature.defaultEnumValue
        }
        return source.currentEnumValue(of: feature)
    }
}
