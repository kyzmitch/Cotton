//
//  LocalFeatureSource.swift
//  catowser
//
//  Created by Andrei Ermoshin on 2/22/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import ReactiveSwift
#if canImport(Combine)
import Combine
#endif

// FeatureSource that uses UserDefaults
final class LocalFeatureSource: FeatureSource {
    
    /// Used to publish Feature changes
    private let (featureChangeSignal, featureObserver) = Signal<AnyFeature, Never>.pipe()
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    private lazy var featureSubject: PassthroughSubject<AnyFeature, Never> = .init()
    
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
    
    func setValue<F>(of feature: ApplicationFeature<F>, value: F.Value?) where F: BasicFeature {
        switch F.defaultValue {
        case is Bool:
            // swiftlint:disable:next force_cast
            let boolValue = value as! Bool
            LocalSettings.setGlobalBoolSetting(for: F.key.prefixed(), value: boolValue)
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

extension LocalFeatureSource: ObservableFeatureSource {
    var rxFutureFeatureChanges: Signal<AnyFeature, Never> {
        return featureChangeSignal
    }

    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    var futureFeatureChanges: AnyPublisher<AnyFeature, Never> {
        return featureSubject.eraseToAnyPublisher()
    }
}

private extension String {
    func prefixed() -> String {
        return "CottonPrefix-"+self
    }
}
