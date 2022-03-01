//
//  SettingsEnumTypes.swift
//  catowser
//
//  Created by Andrey Ermoshin on 26.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import CoreBrowser
import FeaturesFlagsKit

/// Web search completion source
enum WebAutoCompletionSource: Int, CaseIterable {
    case google
    case duckduckgo
}

extension WebAutoCompletionSource: EnumDefaultValueSupportable {
    public var defaultValue: WebAutoCompletionSource {
        return .duckduckgo
    }
}

/// More simple analog for HttpKit.ResponseHandlingApi
enum AsyncApiType: Int, CaseIterable {
    case reactive
    case combine
    case asyncAwait
}

extension AsyncApiType: EnumDefaultValueSupportable {
    public var defaultValue: AsyncApiType {
        return .combine
    }
}

// MARK: - types from CoreBrowser

extension AddedTabPosition: EnumDefaultValueSupportable {
    public var defaultValue: AddedTabPosition {
        return .listEnd
    }
}

extension TabContentDefaultState: EnumDefaultValueSupportable {
    public var defaultValue: TabContentDefaultState {
        return .favorites
    }
}
