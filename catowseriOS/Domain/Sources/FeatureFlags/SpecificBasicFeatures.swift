//
//  SpecificBasicFeatures.swift
//  catowser
//
//  Created by Andrei Ermoshin on 5/29/20.
//  Copyright © 2020 Cotton (former Catowser). All rights reserved.
//

import CoreBrowser
import FeatureFlagsKit

extension ApplicationFeature {
    /// DNS over HTTPs is available or not
    public static var dnsOverHTTPSAvailable: ApplicationFeature<DoHAvailable> {
        return ApplicationFeature<DoHAvailable>()
    }
    static var javaScriptEnabled: ApplicationFeature<JavaScriptEnabled> {
        return ApplicationFeature<JavaScriptEnabled>()
    }
    static var nativeAppRedirect: ApplicationFeature<NativeAppRedirect> {
        return ApplicationFeature<NativeAppRedirect>()
    }
}

/// DNS over HTTPS
public enum DoHAvailable: BasicFeature {
    /// Feature value type
    public typealias Value = Bool
    /// Key of feature to find/save in source
    public static let key = "ios.doh"
    /// Default value when it is not stored in the source yet
    public static let defaultValue = false
    /// Source where the value is stored
    public static let source: FeatureSource.Type = LocalFeatureSource.self
}

/// State of JavaScript in webview.
enum JavaScriptEnabled: BasicFeature {
    typealias Value = Bool
    static let key: String = "ios.js.enabled"
    static let defaultValue: Bool = true
    static let source: FeatureSource.Type = LocalFeatureSource.self
}

/// Native app redirect
enum NativeAppRedirect: BasicFeature {
    typealias Value = Bool
    static let key = "ios.native-app-redirect"
    /// By default it is disabled, but default value for OS is enabled.
    /// This is because in Cotton app it is desired to keep user in the app
    /// even for native app links to allow use html content.
    /// But would be good to quickly revert this feature.
    static let defaultValue = false
    static let source: FeatureSource.Type = LocalFeatureSource.self
}
