//
//  SiteSettings+Extensions.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/2/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import WebKit
import CoreHttpKit

extension Site.Settings {
    /// This will be ignored for old WebViews because it can't be changed for existing WebView without recration.
    var webViewConfig: WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptEnabled = isJSEnabled
        configuration.processPool = WKProcessPool()
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = !blockPopups
#if os(iOS)
        // We do this to go against the configuration of the <meta name="viewport">
        // tag to behave the same way as Safari :-(
        configuration.ignoresViewportScaleLimits = true
#endif
        if isPrivate {
            configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        }

        return configuration
    }
}

extension Site.Settings: CustomStringConvertible {
    public override var description: String {
        return "private: \(isPrivate) popupsBlock: \(blockPopups) js: \(isJSEnabled) plugins: \(canLoadPlugins)"
    }
}
