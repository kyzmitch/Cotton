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
    static var tabAddPosition: ApplicationFeature<TabAddPosition> {
        return ApplicationFeature<TabAddPosition>()
    }
    static var tabDefaultContent: ApplicationFeature<TabDefaultContent> {
        return ApplicationFeature<TabDefaultContent>()
    }
    static var appDefaultAsyncApi: ApplicationFeature<SelectedAppAsyncApi> {
        return ApplicationFeature<SelectedAppAsyncApi>()
    }
}

/// More simple analog for HttpKit.ResponseHandlingApi
enum AsyncApiType: Int, CaseIterable {
    case reactive
    case combine
    case asyncAwait
}

/// Async Api type
enum SelectedAppAsyncApi: BasicFeature {
    typealias Value = AsyncApiType.RawValue
    static let key = "ios.browser.async_api"
    static let defaultValue: AsyncApiType.RawValue = defaultNotRawValue.rawValue
    static let source: FeatureSource.Type = LocalFeatureSource.self
    
    static let defaultNotRawValue: AsyncApiType = {
        if #available(iOS 15.0, *) {
#if swift(>=5.5)
            return .asyncAwait
#else
            return .combine
#endif
        } else if #available(iOS 13.0, *) {
            return .combine
        } else {
            return .reactive
        }
    }()
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

/// Tab add strategy on UI
enum TabAddPosition: BasicFeature {
    typealias Value = AddedTabPosition.RawValue
    static let key = "ios.tab.add_position"
    static let defaultValue: AddedTabPosition.RawValue = AddedTabPosition.listEnd.rawValue
    static let source: FeatureSource.Type = LocalFeatureSource.self
}

enum TabDefaultContent: BasicFeature {
    typealias Value = TabContentDefaultState.RawValue
    static let key = "ios.tab.default_content"
    static let defaultValue: TabContentDefaultState.RawValue = TabContentDefaultState.topSites.rawValue
    static let source: FeatureSource.Type = LocalFeatureSource.self
}
