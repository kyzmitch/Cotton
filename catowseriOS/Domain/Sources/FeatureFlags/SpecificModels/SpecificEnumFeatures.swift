//
//  SpecificEnumFeatures.swift
//  catowser
//
//  Created by Andrey Ermoshin on 26.02.2022.
//  Copyright © 2022 Cotton (former Catowser). All rights reserved.
//

import Foundation
import CoreBrowser
import FeatureFlagsKit
import CottonTabs

extension String {
    static let autoCompletionKey = "ios.browser.autocompletion.source"
    static let tabAddPositionKey = "ios.tab.add_position"
    static let tabDefaultContentKey = "ios.tab.default_content"
    static let browserAsyncApiKey = "ios.browser.async_api"
    static let observingApiKey = "ios.browser.observing_api"
}

/// Web auto-completion feature
public typealias WebAutoCompletionFeature = GenericEnumFeature<WebAutoCompletionSource>
/// Enum feature for tab add position
public typealias TabAddPositionFeature = GenericEnumFeature<AddedTabPosition>
/// Tab default content feature
public typealias TabContentFeature = GenericEnumFeature<CoreBrowser.Tab.ContentType>
/// App async API type feature
public typealias AppAsyncApiFeature = GenericEnumFeature<AsyncApiType>
/// Observing API type
public typealias ObservingApiFeature = GenericEnumFeature<ObservingApiType>

/// Enum features holder.
///
/// Now it needs to be public to extend it in the ViewsBase in Presentation for ui framework type
public enum EnumFeaturesHolder {
    static let webAutoCompletionSource = WebAutoCompletionFeature(.autoCompletionKey)
    static let tabAddPosition = TabAddPositionFeature(.tabAddPositionKey)
    static let tabDefaultContent = TabContentFeature(.tabDefaultContentKey)
    static let selectedAppAsyncApi = AppAsyncApiFeature(.browserAsyncApiKey)
    static let observingApiKey = ObservingApiFeature(.observingApiKey)
}

extension GenericEnumFeature where E == AsyncApiType {
    var defaultEnumValue: AsyncApiType {
        if #available(iOS 15.0, *) {
            #if swift(>=5.5)
            return .asyncAwait
            #else
            return .combine
            #endif
        } else {
            return .combine
        }
    }
}

extension GenericEnumFeature where E == ObservingApiType {
    var defaultEnumValue: ObservingApiType {
        if #available(iOS 17.0, *) {
            return .observerDesignPattern
        } else {
            return .observerDesignPattern
        }
    }
}
