//
//  AnyFeature.swift
//  catowser
//
//  Created by Andrey Ermoshin on 26.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation

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
