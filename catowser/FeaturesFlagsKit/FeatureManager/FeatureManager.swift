//
//  FeatureManager.swift
//  catowser
//
//  Created by Andrei Ermoshin on 2/22/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import CoreBrowser

public final class FeatureManager {
    /// Shared instance has to be internal, to be able to divide code on extensions in separate files
    static let shared: FeatureManager = .init()
    /// fields have to be internal, to be able to move code to extensions in separate files
    let sources: [FeatureSource] = [LocalFeatureSource() /*, RemoteFeatureSource()*/]
    /// temporarily create a separate array of sources for enum features
    let enumSources: [EnumFeatureSource] = [LocalFeatureSource()]
    
    private init() {}
    
    public static func boolValue<F: BasicFeature>(of feature: ApplicationFeature<F>) -> Bool where F.Value == Bool {
        guard let source = source(for: feature) else {
            return F.defaultValue
        }
        return source.currentValue(of: feature)
    }
    
    public static func intValue<F: BasicFeature>(of feature: ApplicationFeature<F>) -> Int where F.Value == Int {
        guard let source = source(for: feature) else {
            return F.defaultValue
        }
        return source.currentValue(of: feature)
    }
}
