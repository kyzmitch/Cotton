//
//  FeatureManager+BasicFeatures.swift
//  catowser
//
//  Created by Andrey Ermoshin on 26.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

#if canImport(Combine)
import Combine
#endif
import ReactiveSwift

// MARK: - basic features

extension FeatureManager {
    static func setFeature<F: BasicFeature>(_ feature: ApplicationFeature<F>, value: F.Value?) {
        guard let source = source(for: feature) else {
            return
        }
        source.setValue(of: feature, value: value)
    }
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    typealias AppFeaturePublisher<F: Feature> = AnyPublisher<ApplicationFeature<F>, Never>
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    static func featureChangesPublisher<F>(for feature: ApplicationFeature<F>) -> AppFeaturePublisher<F> {
        guard let source = source(for: feature) as? ObservableFeatureSource else {
            let empty = Empty<ApplicationFeature<F>, Never>(completeImmediately: false)
            return empty.eraseToAnyPublisher()
        }
        return source.futureFeatureChanges
            .compactMap { $0 == feature ? feature : nil }
            .eraseToAnyPublisher()
    }
    
    static func rxFeatureChanges<F>(for feature: ApplicationFeature<F>) -> Signal<ApplicationFeature<F>, Never> {
        guard let source = source(for: feature) as? ObservableFeatureSource else {
            return .empty
        }
        return source.rxFutureFeatureChanges
            .filterMap { $0 == feature ? feature : nil }
    }
    
    static func source<F>(for feature: ApplicationFeature<F>) -> FeatureSource? {
        return shared.sources.first(where: { type(of: $0) == F.source })
    }
}
