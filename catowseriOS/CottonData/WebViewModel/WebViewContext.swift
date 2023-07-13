//
//  WebViewContext.swift
//  catowser
//
//  Created by Andrei Ermoshin on 8/4/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import JSPlugins
import CottonBase
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
    func nativeApp(for host: CottonBase.Host) -> String?
    /// Hides app specific feature for JS value
    func isJavaScriptEnabled() -> Bool
    /// Hides app specific feature value for DNS over HTTPs
    func isDohEnabled() -> Bool
    /// Hides app specific feature value for Native app redirects
    func allowNativeAppRedirects() -> Bool
    /// Wrapper for feature value from specific app
    func appAsyncApiTypeValue() -> AsyncApiType
    /// Update tab's content after loading finish in case if there was a redirect and URL was changed.
    /// Also, this method is needed because need to remember loaded site only when
    /// it was successfully loaded which happens right before this method is getting called.
    ///
    /// No need to call this method if the loading was initiated from top sites or
    /// during app start when the site is already in the tabs cache.
    func updateTabContent(_ site: Site) throws
}
