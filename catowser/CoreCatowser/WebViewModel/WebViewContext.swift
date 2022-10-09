//
//  WebViewContext.swift
//  catowser
//
//  Created by Andrei Ermoshin on 8/4/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import JSPlugins
import CoreHttpKit
import FeaturesFlagsKit
import CoreBrowser

/**
 For more info about usage any keyword see:
 https://swiftrocks.com/whats-any-understanding-type-erasure-in-swift
 */

/// web view context should carry some data or dependencies which can't be stored as a state and always are present
public protocol WebViewContext {
    /// Plugins are optional because there is possibility that js files are not present or plugins delegates are not set
    var pluginsProgram: any JSPluginsProgram { get }
    /// Hides app specific implementation for host check
    func nativeApp(for host: Host) -> String?
    /// Hides app specific feature for JS value
    func isJavaScriptEnabled() -> Bool
    /// Hides app specific feature value for DNS over HTTPs
    func isDohEnabled() -> Bool
    /// Wrapper for feature value from specific app
    func appAsyncApiTypeValue() -> AsyncApiType
    /// Wrapper around CoreBrowser entity which is initialized only in app
    func updateTabContent(_ site: Site) throws
}
