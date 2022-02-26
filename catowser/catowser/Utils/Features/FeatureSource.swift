//
//  FeatureSource.swift
//  catowser
//
//  Created by Andrey Ermoshin on 26.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import ReactiveSwift
#if canImport(Combine)
import Combine
#endif

protocol FeatureSource {
    func currentValue<F: BasicFeature>(of feature: ApplicationFeature<F>) -> F.Value
    func setValue<F: BasicFeature>(of feature: ApplicationFeature<F>, value: F.Value?)
}

/**
 Replace all cases where NoError was used in a Signal or SignalProducer with Never
 https://github.com/ReactiveCocoa/ReactiveSwift/releases/tag/6.0.0
 */
protocol ObservableFeatureSource {
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    var futureFeatureChanges: AnyPublisher<AnyFeature, Never> { get }
    var rxFutureFeatureChanges: Signal<AnyFeature, Never> { get }
}
