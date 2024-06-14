//
//  LocalFeatureSource.swift
//  FeaturesFlagsKit
//
//  Created by Andrei Ermoshin on 2/22/20.
//  Copyright © 2020 Cotton (former Catowser). All rights reserved.
//

import Foundation
@preconcurrency import ReactiveSwift
import Combine

/// FeatureSource that uses UserDefaults
public final class LocalFeatureSource {
    private let (featureChangeSignal, featureObserver) = Signal<AnyFeature, Never>.pipe()
    private lazy var featureSubject: PassthroughSubject<AnyFeature, Never> = .init()

    init() {}
}

extension LocalFeatureSource: ObservableFeatureSource {
    var rxFutureFeatureChanges: Signal<AnyFeature, Never> {
        return featureChangeSignal
    }
    var futureFeatureChanges: AnyPublisher<AnyFeature, Never> {
        return featureSubject.eraseToAnyPublisher()
    }
}

extension LocalFeatureSource: FeatureSource {
    public func currentValue<F: BasicFeature>(of feature: ApplicationFeature<F>) -> F.Value {
        switch F.defaultValue {
        case is String:
            guard let result = LocalSettings.getGlobalStringSetting(for: F.key.prefixedBasic()) else {
                return F.defaultValue
            }
            return result as? F.Value ?? F.defaultValue
        case is Int:
            let savedNumber = LocalSettings.getGlobalIntSetting(for: F.key.prefixedBasic())
            return savedNumber as? F.Value ?? F.defaultValue
        case is Bool:
            guard let globalSetting = LocalSettings.getGlobalBoolSetting(for: F.key.prefixedBasic()) else {
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
            LocalSettings.setGlobalBoolSetting(for: F.key.prefixedBasic(), value: boolValue)
        case is Int:
            // swiftlint:disable:next force_cast
            let intValue = value as! Int
            LocalSettings.setGlobalIntSetting(for: F.key.prefixedBasic(), value: intValue)
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

extension LocalFeatureSource: EnumFeatureSource {
    public func currentEnumValue<F: EnumFeature>(of feature: ApplicationEnumFeature<F>) -> F.EnumValue
    where F.EnumValue.RawValue == Int {
        guard let result = LocalSettings.getGlobalIntSetting(for: feature.feature.key.prefixedEnum()) else {
            return feature.defaultEnumValue
        }
        return F.EnumValue(rawValue: result) ?? feature.defaultEnumValue
    }

    public func setEnumValue<F: EnumFeature>(of feature: ApplicationEnumFeature<F>, value: F.EnumValue?)
    where F.EnumValue.RawValue == Int {
        guard let intValue = value?.rawValue else {
            return
        }
        LocalSettings.setGlobalIntSetting(for: feature.feature.key.prefixedEnum(), value: intValue)

        let value = AnyFeature(feature)
        if #available(iOS 13.0, *) {
            self.featureSubject.send(value)
        }
        self.featureObserver.send(value: value)
    }
}

private extension String {
    func prefixedEnum() -> String {
        return "CottonPrefix-Enum"+self
    }

    func prefixedBasic() -> String {
        return "CottonPrefix-Basic"+self
    }
}
