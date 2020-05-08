//
//  FeatureManager.swift
//  catowser
//
//  Created by Andrei Ermoshin on 2/22/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation

final class FeatureManager {
    private static let shared: FeatureManager = .init()
    private let sources: [FeatureSource] = [LocalFeatureSource() /*, RemoteFeatureSource()*/]
    
    private init() {}
    
    static func boolValue<F: BasicFeature>(of feature: ApplicationFeature<F>) -> Bool where F.Value == Bool {
        guard let source = source(for: feature) else {
            return F.defaultValue
        }
        return source.currentValue(of: feature)
    }
    
    static func setFeature<F: BasicFeature>(_ feature: ApplicationFeature<F>, value: F.Value?) {
        guard let source = source(for: feature) else {
            return
        }
        source.setValue(of: feature, value: value)
    }
    
    // TODO: implement feature state observer (e.g. needed to reload web view)
    
    private static func source<F>(for feature: ApplicationFeature<F>) -> FeatureSource? {
        return shared.sources.first(where: { type(of: $0) == F.source })
    }
}
