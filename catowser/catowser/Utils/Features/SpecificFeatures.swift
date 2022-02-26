//
//  SpecificFeatures.swift
//  catowser
//
//  Created by Andrei Ermoshin on 5/29/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import CoreBrowser

extension ApplicationFeature {
    static var dnsOverHTTPSAvailable: ApplicationFeature<DoHAvailable> {
        return ApplicationFeature<DoHAvailable>()
    }
    static var javaScriptEnabled: ApplicationFeature<JavaScriptEnabled> {
        return ApplicationFeature<JavaScriptEnabled>()
    }
}

/// DNS over HTTPS
enum DoHAvailable: BasicFeature {
    typealias Value = Bool
    static let key = "ios.doh"
    static let defaultValue = false
    static let source: FeatureSource.Type = LocalFeatureSource.self
}

/// State of JavaScript in webview.
enum JavaScriptEnabled: BasicFeature {
    typealias Value = Bool
    static let key: String = "ios.js.enabled"
    static let defaultValue: Bool = true
    static let source: FeatureSource.Type = LocalFeatureSource.self
}
