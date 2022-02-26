//
//  SpecificEnumFeatures.swift
//  catowser
//
//  Created by Andrey Ermoshin on 26.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import CoreBrowser

extension String {
    static let autoCompletionKey = "ios.browser.autocompletion.source"
    static let tabAddPositionKey = "ios.tab.add_position"
    static let tabDefaultContentKey = "ios.tab.default_content"
    static let browserAsyncApiKey = "ios.browser.async_api"
}

typealias WebAutoCompletionFeature = GenericEnumFeature<WebAutoCompletionSource>
typealias TabAddPositionFeature = GenericEnumFeature<AddedTabPosition>
typealias TabContentFeature = GenericEnumFeature<TabContentDefaultState>
typealias AppAsyncApiFeature = GenericEnumFeature<AsyncApiType>

enum EnumFeaturesHolder {
    static let webAutoCompletionSource = WebAutoCompletionFeature(.autoCompletionKey)
    static let tabAddPosition = TabAddPositionFeature(.tabAddPositionKey)
    static let tabDefaultContent = TabContentFeature(.tabDefaultContentKey)
    static let selectedAppAsyncApi = AppAsyncApiFeature(.browserAsyncApiKey)
}

extension GenericEnumFeature where E == AsyncApiType {
    var defaultEnumValue: AsyncApiType {
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
    }
}
