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
public final class LocalFeatureSource {
    /// Used to publish Feature changes
    let (featureChangeSignal, featureObserver) = Signal<AnyFeature, Never>.pipe()
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    lazy var featureSubject: PassthroughSubject<AnyFeature, Never> = .init()
    
    init() {}
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
