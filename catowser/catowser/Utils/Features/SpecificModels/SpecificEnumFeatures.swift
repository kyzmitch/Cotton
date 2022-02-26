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

typealias SelectedWebAutoCompletionSource = GenericEnumFeature<WebAutoCompletionSource>
typealias TabAddPosition = GenericEnumFeature<AddedTabPosition>
typealias TabDefaultContent = GenericEnumFeature<TabContentDefaultState>
typealias SelectedAppAsyncApi = GenericEnumFeature<AsyncApiType>

enum EnumFeaturesHolder {
    static let selectedWebAutoCompletionSource = SelectedWebAutoCompletionSource(.autoCompletionKey)
    static let tabAddPosition = TabAddPosition(.tabAddPositionKey)
    static let tabDefaultContent = TabDefaultContent(.tabDefaultContentKey)
    static let selectedAppAsyncApi = SelectedAppAsyncApi(.browserAsyncApiKey)
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
