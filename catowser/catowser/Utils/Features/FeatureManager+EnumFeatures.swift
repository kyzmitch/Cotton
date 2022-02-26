//
//  FeatureManager+EnumFeatures.swift
//  catowser
//
//  Created by Andrey Ermoshin on 26.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation

extension FeatureManager {
    static func source<F>(for enumFeature: ApplicationEnumFeature<F>) -> FeatureSource? {
        return shared.sources.first(where: { type(of: $0) == F.source })
    }
}
