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

public struct Site {
    /// Initial url
    public let url: HttpKit.URLIpInfo
    public var host: HttpKit.Host {
        return url.host
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
        return searchSuggestion ?? url.domainURL.absoluteString
    }

    private let isPrivate: Bool = false

    private let blockPopups: Bool = DefaultTabProvider.shared.blockPopups

    public let canLoadPlugins: Bool = true
    
    public init?(url: URL, searchSuggestion: String? = nil) {
        guard let urlInfo = HttpKit.URLIpInfo(url) else {
            return nil
        }
        self.url = urlInfo
        self.searchSuggestion = searchSuggestion
        userSpecifiedTitle = nil
        highQualityFaviconImage = nil
    }

    public init?(urlString: String, customTitle: String? = nil, image: UIImage? = nil) {
        guard let decodedUrl = URL(string: urlString) else {
            return nil
        }
        guard let urlInfo = HttpKit.URLIpInfo(decodedUrl) else {
            return nil
        }
        url = urlInfo
        searchSuggestion = nil
        userSpecifiedTitle = customTitle
        highQualityFaviconImage = image
    }

    /// This will be ignored for old WebViews because it can't be changed for existing WebView without recration.
    public var webViewConfig: WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptEnabled = true
        configuration.processPool = WKProcessPool()
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = !blockPopups
        // We do this to go against the configuration of the <meta name="viewport">
        // tag to behave the same way as Safari :-(
        configuration.ignoresViewportScaleLimits = true
        if isPrivate {
            configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        }

        return configuration
    }
}

extension Site: Equatable {}

extension URL {
    public init?(faviconHost: HttpKit.Host) {
        let format = "https://\(faviconHost.rawValue)/favicon.ico"
        self.init(string: format)
    }
    
    public init?(faviconIPInfo: HttpKit.URLIpInfo) {
        guard let ipAddress = faviconIPInfo.ipAddress else {
            return nil
        }
        let format = "https://\(ipAddress)/favicon.ico"
        self.init(string: format)
    }
}
