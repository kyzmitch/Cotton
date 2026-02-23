//
//  SettingsEnumTypes.swift
//  catowser
//
//  Created by Andrey Ermoshin on 26.02.2022.
//  Copyright © 2022 Cotton (former Catowser). All rights reserved.
//

import Foundation
import CoreBrowser
import FeatureFlagsKit
import CottonTabs
import ViewsBase

extension WebAutoCompletionSource: EnumDefaultValueSupportable {
    public var defaultValue: WebAutoCompletionSource {
        // Google doesn't work for now due to API response changes or something else
        return .duckduckgo
    }
}

extension AsyncApiType: @retroactive EnumDefaultValueSupportable {
    public var defaultValue: AsyncApiType {
        return .asyncAwait
    }
}

extension ObservingApiType: @retroactive EnumDefaultValueSupportable {
    public var defaultValue: ObservingApiType {
        return .observerDesignPattern
    }
}

// MARK: - types from CoreBrowser

extension AddedTabPosition: @retroactive EnumDefaultValueSupportable {
    public var defaultValue: AddedTabPosition {
        return .listEnd
    }
}

extension CoreBrowser.Tab.ContentType: @retroactive EnumDefaultValueSupportable {
    public var defaultValue: CoreBrowser.Tab.ContentType {
        #if DEBUG
        return CoreBrowser.Tab.ContentType.topSites
        #else
        // In Release builds only User can decide which web sites to show by default
        return CoreBrowser.Tab.ContentType.favorites
        #endif
    }
}

extension UIFrameworkType: EnumDefaultValueSupportable {
    var defaultValue: UIFrameworkType {
        return .uiKit
    }
}
