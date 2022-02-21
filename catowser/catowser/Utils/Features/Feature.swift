//
//  Feature.swift
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

protocol FeatureSource {
    func currentValue<F: BasicFeature>(of feature: ApplicationFeature<F>) -> F.Value
    func setValue<F: BasicFeature>(of feature: ApplicationFeature<F>, value: F.Value?)
}

protocol ObservableFeatureSource {
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    var futureFeatureChanges: AnyPublisher<AnyFeature, Never> { get }
    var rxFutureFeatureChanges: Signal<AnyFeature, Never> { get }
}

/**
 Replace all cases where NoError was used in a Signal or SignalProducer with Never
 https://github.com/ReactiveCocoa/ReactiveSwift/releases/tag/6.0.0
 */

protocol BasicFeature: Feature where Value: RawFeatureValue {
}

protocol EnumFeature: BasicFeature {
    associatedtype NonRawValue: CaseIterable
    
    static var defaultNotRawValue: NonRawValue { get }
}

struct GenericEnumFeature<EnumType: CaseIterable & RawRepresentable>: EnumFeature {
    typealias Value = EnumType.RawValue
    typealias NonRawValue = EnumType
    static var key: String = "ios.browser.autocompletion.source"
    static var defaultValue: WebAutoCompletionSource.RawValue = defaultNotRawValue.rawValue
    static let defaultNotRawValue: WebAutoCompletionSource = .duckduckgo
    static var source: FeatureSource.Type = LocalFeatureSource.self
}

protocol Feature {
    associatedtype Value

    static var source: FeatureSource.Type { get }
    static var defaultValue: Value { get }
    static var key: String { get }
    static var name: String { get }
    static var description: String { get }
}

extension Feature {
    static var name: String {
        return key
    }
    static var description: String {
        return "\(name) feature"
    }
}

// Raw types of features we support.
protocol RawFeatureValue {}
extension Bool: RawFeatureValue {}
extension Int: RawFeatureValue {}
extension String: RawFeatureValue {}

// Unless specified all Basic Features will be local
extension BasicFeature {
    static var source: FeatureSource.Type {
        return LocalFeatureSource.self
    }
}

/// For `syntatic sugar`
struct ApplicationFeature<F: Feature> {
    var defaultValue: F.Value {
        return F.defaultValue
    }
}

/// Feature description.
/// Wrapper around generic ApplicationFeature to get rid of template
struct AnyFeature: Equatable {
    private let featureType: Any.Type
    private let key: String
    init<F: Feature>(_ featureType: F.Type) {
        self.key = F.key
        self.featureType = featureType
    }
    
    init<F>(_ feature: ApplicationFeature<F>) {
        self.key = F.key
        self.featureType = F.self
    }
    
    static func == (lhs: AnyFeature, rhs: AnyFeature) -> Bool {
        return lhs.featureType == rhs.featureType
    }

    static func == <F>(lhs: AnyFeature, rhs: ApplicationFeature<F>) -> Bool {
        return lhs == AnyFeature(rhs)
    }

    static func == <F>(lhs: ApplicationFeature<F>, rhs: AnyFeature) -> Bool {
        return AnyFeature(lhs) == rhs
    }
}
