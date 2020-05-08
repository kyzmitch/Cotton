//
//  Feature.swift
//  catowser
//
//  Created by Andrei Ermoshin on 2/22/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation

protocol FeatureSource {
    func currentValue<F: BasicFeature>(of feature: ApplicationFeature<F>) -> F.Value
    func setValue<F: BasicFeature>(of feature: ApplicationFeature<F>, value: F.Value?)
}

protocol BasicFeature: Feature where Value: RawFeatureValue {
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

struct ApplicationFeature<F: Feature> {
    static var dnsOverHTTPSAvailable: ApplicationFeature<DoHAvailable> {
        return ApplicationFeature<DoHAvailable>()
    }
}

/// DNS over HTTPS
enum DoHAvailable: BasicFeature {
    typealias Value = Bool
    static let key = "ios.doh"
    static let defaultValue = false
    static var source: FeatureSource.Type = LocalFeatureSource.self
}
