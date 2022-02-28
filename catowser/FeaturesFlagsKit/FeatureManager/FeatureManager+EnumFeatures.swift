//
//  FeatureManager+EnumFeatures.swift
//  FeaturesFlagsKit
//
//  Created by Andrey Ermoshin on 26.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CoreBrowser

extension FeatureManager {
    public static func setFeature<F: EnumFeature>(_ feature: ApplicationEnumFeature<F>, value: F.EnumValue?)
    where F.EnumValue.RawValue == Int {
        guard let source = source(for: feature) else {
            return
        }
        source.setEnumValue(of: feature, value: value)
    }
    
    public static func source<F: EnumFeature>(for enumFeature: ApplicationEnumFeature<F>) -> EnumFeatureSource? {
        return shared.enumSources.first(where: { type(of: $0) == enumFeature.feature.source})
    }
}
