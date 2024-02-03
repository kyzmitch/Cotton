//
//  SettingsEnumTypes.swift
//  catowser
//
//  Created by Andrey Ermoshin on 26.02.2022.
//  Copyright © 2022 Cotton (former Catowser). All rights reserved.
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
#if DEBUG
        return TabContentDefaultState.topSites
#else
        // In Release builds only User can decide which web sites to show by default
        return TabContentDefaultState.favorites
#endif
    }
}

// MARK: - UI settings

enum UIFrameworkType: Int, CaseIterable {
    /// Good old UIKit views
    case uiKit
    /// SwiftUI view wraps UIKit view controller
    case swiftUIWrapper
    /// Clear SwiftUI views without re-using UIKit
    case swiftUI
    
    var swiftUIBased: Bool {
        switch self {
        case .swiftUI, .swiftUIWrapper:
            return true
        case .uiKit:
            return false
        }
    }
    
    /// Fully without UIKit
    var isUIKitFree: Bool {
        self == .swiftUI
    }
    
    var uiKitBased: Bool {
        switch self {
        case .uiKit, .swiftUIWrapper:
            return true
        case .swiftUI:
            return false
        }
    }
}

extension UIFrameworkType: EnumDefaultValueSupportable {
    var defaultValue: UIFrameworkType {
        return .uiKit
    }
}
