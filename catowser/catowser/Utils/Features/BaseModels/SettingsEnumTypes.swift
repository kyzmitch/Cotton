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
        // Google doesn't work for now due to API response changes or something else
        return .duckduckgo
    }
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
