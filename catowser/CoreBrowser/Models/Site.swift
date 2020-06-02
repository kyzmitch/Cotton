//
//  Site.swift
//  catowser
//
//  Created by Andrei Ermoshin on 01/02/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import WebKit
import UIKit
import HttpKit

extension Site {
    public struct Settings {
        public let isPrivate: Bool = false

        public let blockPopups: Bool
        
        public let isJsEnabled: Bool

        public let canLoadPlugins: Bool = true
    }
}

public struct Site {
    /// Initial url
    public let urlInfo: HttpKit.URLIpInfo
    public var host: HttpKit.Host {
        return urlInfo.host
    }
    /// Used by top sites by loading high quality image from Assets
    public var highQualityFaviconImage: UIImage?

    /// String associated with site if site was created from search engine.
    /// This convinient property to transfer/save search query to use it for search view.
    /// Different approach could be to store it in tab content type `.site` state as 2nd associated value.
    public let searchSuggestion: String?

    public var title: String {
        if let search = searchSuggestion {
            return search
        } else if let userSpecific = userSpecifiedTitle {
            return userSpecific
        } else {
            return host.rawValue
        }
    }

    public let userSpecifiedTitle: String?

    public var searchBarContent: String {
        return searchSuggestion ?? urlInfo.domainURL.absoluteString
    }

    public let settings: Settings
    
    public init?(url: URL,
                 searchSuggestion: String? = nil,
                 blockPopups: Bool,
                 javaScriptEnabled: Bool = true) {
        guard let urlInfo = HttpKit.URLIpInfo(url) else {
            return nil
        }
        self.urlInfo = urlInfo
        self.searchSuggestion = searchSuggestion
        userSpecifiedTitle = nil
        highQualityFaviconImage = nil
        settings = Settings(blockPopups: blockPopups,
                            isJsEnabled: javaScriptEnabled)
    }

    public init?(urlString: String,
                 customTitle: String? = nil,
                 image: UIImage? = nil,
                 blockPopups: Bool,
                 javaScriptEnabled: Bool = true) {
        guard let decodedUrl = URL(string: urlString) else {
            return nil
        }
        guard let urlInfo = HttpKit.URLIpInfo(decodedUrl) else {
            return nil
        }
        self.urlInfo = urlInfo
        searchSuggestion = nil
        userSpecifiedTitle = customTitle
        highQualityFaviconImage = image
        settings = Settings(blockPopups: blockPopups,
                            isJsEnabled: javaScriptEnabled)
    }

    /// This will be ignored for old WebViews because it can't be changed for existing WebView without recration.
    public var webViewConfig: WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptEnabled = settings.isJsEnabled
        configuration.processPool = WKProcessPool()
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = !settings.blockPopups
        // We do this to go against the configuration of the <meta name="viewport">
        // tag to behave the same way as Safari :-(
        configuration.ignoresViewportScaleLimits = true
        if settings.isPrivate {
            configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        }

        return configuration
    }
}

extension Site.Settings: Equatable {}
extension Site: Equatable {}
