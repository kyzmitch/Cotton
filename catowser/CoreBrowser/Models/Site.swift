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

public struct Site {
    /// Initial url
    public let url: URL
    public let host: String
    public let faviconURL: URL
    /// Only used by top sites by loading image from Assets
    public let faviconImage: UIImage?

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
            return host
        }
    }

    public let userSpecifiedTitle: String?

    public var searchBarContent: String {
        return searchSuggestion ?? url.absoluteString
    }

    private let isPrivate: Bool = false

    private let blockPopups: Bool = true

    public let canLoadPlugins: Bool = true
    
    public init?(url: URL, searchSuggestion: String? = nil) {
        guard let decodedHost = url.host else {
            return nil
        }
        host = decodedHost
        guard let faviconURL = URL(faviconHost: host) else {
            return nil
        }
        self.faviconURL = faviconURL
        self.url = url
        self.searchSuggestion = searchSuggestion
        userSpecifiedTitle = nil
        faviconImage = nil
    }

    public init?(urlString: String, customTitle: String? = nil, image: UIImage? = nil) {
        guard let decodedUrl = URL(string: urlString) else {
            return nil
        }
        url = decodedUrl
        // For http://www.opennet.ru/opennews/art.shtml?num=50072
        // it should be "www.opennet.ru"
        // Add parsing of host https://tools.ietf.org/html/rfc1738#section-3.1
        // in case if iOS sdk returns nil
        guard let decodedHost = url.host else {
            return nil
        }
        host = decodedHost
        guard let faviconURL = URL(faviconHost: host) else {
            return nil
        }
        self.faviconURL = faviconURL
        searchSuggestion = nil
        userSpecifiedTitle = customTitle
        faviconImage = image
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

fileprivate extension URL {
    init?(faviconHost: String) {
        let format = "https://\(faviconHost)/favicon.ico"
        self.init(string: format)
    }
}
