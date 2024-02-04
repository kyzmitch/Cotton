//
//  SpecificEnumFeatures.swift
//  catowser
//
//  Created by Andrey Ermoshin on 26.02.2022.
//  Copyright © 2022 Cotton (former Catowser). All rights reserved.
//

import Foundation
import CoreBrowser
import FeaturesFlagsKit

extension String {
    static let autoCompletionKey = "ios.browser.autocompletion.source"
    static let tabAddPositionKey = "ios.tab.add_position"
    static let tabDefaultContentKey = "ios.tab.default_content"
    static let browserAsyncApiKey = "ios.browser.async_api"
    static let uiFrameworkKey = "ios.browser.ui_framework"
}

typealias WebAutoCompletionFeature = GenericEnumFeature<WebAutoCompletionSource>
typealias TabAddPositionFeature = GenericEnumFeature<AddedTabPosition>
typealias TabContentFeature = GenericEnumFeature<TabContentDefaultState>
typealias AppAsyncApiFeature = GenericEnumFeature<AsyncApiType>
typealias UIFrameworkFeature = GenericEnumFeature<UIFrameworkType>

enum EnumFeaturesHolder {
    static let webAutoCompletionSource = WebAutoCompletionFeature(.autoCompletionKey)
    static let tabAddPosition = TabAddPositionFeature(.tabAddPositionKey)
    static let tabDefaultContent = TabContentFeature(.tabDefaultContentKey)
    static let selectedAppAsyncApi = AppAsyncApiFeature(.browserAsyncApiKey)
    static let selectedUIFramework = UIFrameworkFeature(.uiFrameworkKey)
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
