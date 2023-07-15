//
//  FeatureManager.swift
//  FeaturesFlagsKit
//
//  Created by Andrei Ermoshin on 2/22/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import CoreBrowser

@globalActor
public final class FeatureManager {
    public static let shared = FManager()
    
    public actor FManager {
        /// Flag value data sources. Have to be internal (not private),
        /// to be able to move code to extensions in separate files
        let sources: [FeatureSource] = [LocalFeatureSource() /*, RemoteFeatureSource()*/]
        /// Temporarily create a separate array of sources for enum features
        let enumSources: [EnumFeatureSource] = [LocalFeatureSource()]
        
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
    }
}
