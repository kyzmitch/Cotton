//
//  Site.swift
//  catowser
//
//  Created by Andrei Ermoshin on 01/02/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import UIKit
import HttpKit

extension Site {
    public struct Settings: Equatable {
        public let isPrivate: Bool = false
        public let blockPopups: Bool
        public var isJsEnabled: Bool
        public let canLoadPlugins: Bool = true
        
        public init(popupsBlock: Bool, javaScriptEnabled: Bool) {
            blockPopups = popupsBlock
            isJsEnabled = javaScriptEnabled
        }
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
                 settings: Settings) {
        guard let urlInfo = HttpKit.URLIpInfo(url) else {
            return nil
        }
        self.urlInfo = urlInfo
        self.searchSuggestion = searchSuggestion
        userSpecifiedTitle = nil
        highQualityFaviconImage = nil
        self.settings = settings
    }

    public init?(urlString: String,
                 customTitle: String? = nil,
                 image: UIImage? = nil,
                 settings: Settings) {
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
        self.settings = settings
    }
}

extension Site: Equatable {}
