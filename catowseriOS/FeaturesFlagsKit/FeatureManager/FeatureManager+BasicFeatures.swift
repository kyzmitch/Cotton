//
//  FeatureManager+BasicFeatures.swift
//  FeaturesFlagsKit
//
//  Created by Andrey Ermoshin on 26.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

#if canImport(Combine)
import Combine
#endif
import ReactiveSwift

// MARK: - basic features

extension FeatureManager.FManager {
    public func setFeature<F: BasicFeature>(_ feature: ApplicationFeature<F>, value: F.Value?) {
        guard let source = source(for: feature) else {
            return
        }
        source.setValue(of: feature, value: value)
    }
    
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
    
    public func source<F>(for feature: ApplicationFeature<F>) -> FeatureSource? {
        return sources.first(where: { type(of: $0) == F.source })
    }
}
