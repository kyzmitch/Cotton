//
//  EnumFeatureSource.swift
//  FeaturesFlagsKit
//
//  Created by Andrey Ermoshin on 26.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import ReactiveSwift
#if canImport(Combine)
import Combine
#endif

public protocol EnumFeatureSource {
    func currentEnumValue<F: EnumFeature>(of feature: ApplicationEnumFeature<F>) -> F.EnumValue
    where F.EnumValue.RawValue == Int
    func setEnumValue<F: EnumFeature>(of feature: ApplicationEnumFeature<F>, value: F.EnumValue?)
    where F.EnumValue.RawValue == Int
}
