//
//  UIFrameworkType+Feature.swift
//  Presentation
//
//  Created by Andrey Ermoshin on 01.03.2026.
//

import CoreBrowser
import FeatureFlagsKit

extension UIFrameworkType: EnumDefaultValueSupportable {
    /// Default value
    public var defaultValue: UIFrameworkType {
        return .uiKit
    }
}

extension String {
    static let uiFrameworkKey = "ios.browser.ui_framework"
}

typealias UIFrameworkFeature = GenericEnumFeature<UIFrameworkType>

extension ApplicationEnumFeature {
    static var appDefaultUIFramework: ApplicationEnumFeature<UIFrameworkFeature> {
        return ApplicationEnumFeature<UIFrameworkFeature>(feature: UIFrameworkFeature(.uiFrameworkKey))
    }
}

// MARK: - GETTER methods specific to Enum features

extension FeatureManager.StateHolder {
    /// Selected App UI framework type
    public func appUIFrameworkValue() async -> UIFrameworkType {
        let feature: ApplicationEnumFeature = .appDefaultUIFramework
        guard let source = source(for: feature) else {
            return feature.defaultEnumValue
        }
        return await source.currentEnumValue(of: feature)
    }
}
