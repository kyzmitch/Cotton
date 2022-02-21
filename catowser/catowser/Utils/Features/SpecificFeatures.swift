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
    static var webAutoCompletionSource: ApplicationFeature<SelectedWebAutoCompletionSource> {
        return ApplicationFeature<SelectedWebAutoCompletionSource>()
    }
}

/// Web search completion source
enum WebAutoCompletionSource: Int, CaseIterable {
    case google
    case duckduckgo
}

enum SelectedWebAutoCompletionSource: EnumFeature {
    typealias Value = WebAutoCompletionSource.RawValue
    typealias NonRawValue = WebAutoCompletionSource
    static var key: String = "ios.browser.autocompletion.source"
    static var defaultValue: WebAutoCompletionSource.RawValue = defaultNotRawValue.rawValue
    static let defaultNotRawValue: WebAutoCompletionSource = .duckduckgo
    static var source: FeatureSource.Type = LocalFeatureSource.self
}

/// More simple analog for HttpKit.ResponseHandlingApi
enum AsyncApiType: Int, CaseIterable {
    case reactive
    case combine
    case asyncAwait
}

/// Async Api type
enum SelectedAppAsyncApi: EnumFeature {
    typealias Value = AsyncApiType.RawValue
    typealias NonRawValue = AsyncApiType
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
enum TabAddPosition: EnumFeature {
    typealias Value = AddedTabPosition.RawValue
    typealias NonRawValue = AddedTabPosition
    static let key = "ios.tab.add_position"
    static let defaultValue: AddedTabPosition.RawValue = defaultNotRawValue.rawValue
    static var defaultNotRawValue: AddedTabPosition = .listEnd
    static let source: FeatureSource.Type = LocalFeatureSource.self
}

enum TabDefaultContent: EnumFeature {
    typealias Value = TabContentDefaultState.RawValue
    typealias NonRawValue = TabContentDefaultState
    static let key = "ios.tab.default_content"
    static let defaultValue: TabContentDefaultState.RawValue = defaultNotRawValue.rawValue
    static var defaultNotRawValue: TabContentDefaultState = .topSites
    static let source: FeatureSource.Type = LocalFeatureSource.self
}
