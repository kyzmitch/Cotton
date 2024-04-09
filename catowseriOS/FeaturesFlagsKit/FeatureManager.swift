//
//  FeatureManager.swift
//  FeaturesFlagsKit
//
//  Created by Andrei Ermoshin on 2/22/20.
//  Copyright © 2020 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation
import CoreBrowser
import ReactiveSwift
import Combine

@globalActor
public final class FeatureManager {
    public static let shared = StateHolder()

    public actor StateHolder {
        /// Flag value data sources.
        private let sources: [FeatureSource] = [LocalFeatureSource() /*, RemoteFeatureSource()*/]
        /// Temporarily create a separate array of sources for enum features
        private let enumSources: [EnumFeatureSource] = [LocalFeatureSource()]

        // MARK: - read

        public func boolValue<F: BasicFeature>(of feature: ApplicationFeature<F>) -> Bool where F.Value == Bool {
            guard let source = source(for: feature) else {
                return F.defaultValue
            }
            return source.currentValue(of: feature)
        }

        public func intValue<F: BasicFeature>(of feature: ApplicationFeature<F>) -> Int where F.Value == Int {
            guard let source = source(for: feature) else {
                return F.defaultValue
            }
            return source.currentValue(of: feature)
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

        // MARK: - write

        public func setFeature<F: BasicFeature>(_ feature: ApplicationFeature<F>, value: F.Value?) {
            guard let source = source(for: feature) else {
                return
            }
            source.setValue(of: feature, value: value)
        }

        public func setFeature<F: EnumFeature>(_ feature: ApplicationEnumFeature<F>, value: F.EnumValue?)
        where F.EnumValue.RawValue == Int {
            guard let source = source(for: feature) else {
                return
            }
            source.setEnumValue(of: feature, value: value)
        }

        // MARK: - sources

        public func source<F>(for feature: ApplicationFeature<F>) -> FeatureSource? {
            return sources.first(where: { type(of: $0) == F.source })
        }

        public func source<F: EnumFeature>(for enumFeature: ApplicationEnumFeature<F>) -> EnumFeatureSource? {
            return enumSources.first(where: { type(of: $0) == enumFeature.feature.source})
        }

        // MARK: - observation

        public typealias AppFeaturePublisher<F: Feature> = AnyPublisher<ApplicationFeature<F>, Never>

        public func featureChangesPublisher<F>(for feature: ApplicationFeature<F>) -> AppFeaturePublisher<F> {
            guard let source = source(for: feature) as? ObservableFeatureSource else {
                let empty = Empty<ApplicationFeature<F>, Never>(completeImmediately: false)
                return empty.eraseToAnyPublisher()
            }
            return source.futureFeatureChanges
                .compactMap { $0 == feature ? feature : nil }
                .eraseToAnyPublisher()
        }

        public func rxFeatureChanges<F>(for feature: ApplicationFeature<F>) -> Signal<ApplicationFeature<F>, Never> {
            guard let source = source(for: feature) as? ObservableFeatureSource else {
                return .empty
            }
            return source.rxFutureFeatureChanges
                .compactMap { $0 == feature ? feature : nil }
        }
    }
}
