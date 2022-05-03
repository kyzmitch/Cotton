//
//  Site.swift
//  catowser
//
//  Created by Andrei Ermoshin on 01/02/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import UIKit
import CoreHttpKit

extension Site {
    public struct Settings: Equatable {
        public let isPrivate: Bool
        public let blockPopups: Bool
        public var isJsEnabled: Bool
        public let canLoadPlugins: Bool = true
        
        public init(popupsBlock: Bool, javaScriptEnabled: Bool, privateTab: Bool = false) {
            blockPopups = popupsBlock
            isJsEnabled = javaScriptEnabled
            isPrivate = privateTab
        }
    }
}

public struct Site {
    /// Initial url
    public let urlInfo: URLInfo
    public var host: Host {
        return urlInfo.host()
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
            return host.rawString
        }
    }

    public let userSpecifiedTitle: String?

    public var searchBarContent: String {
        return searchSuggestion ?? urlInfo.url
    }

    public let settings: Settings
    
    public init?(url: URL,
                 searchSuggestion: String? = nil,
                 settings: Settings) {
        guard let hostString = url.host,
                let domain = try? DomainName(input: hostString) else {
            return nil
        }
        // TODO: parse url.scheme to the enum type from Kotlin
        urlInfo = URLInfo(scheme: HttpScheme.https,
                          remainingURLpart: url.path,
                          domainName: domain,
                          ipAddress: nil)
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
        guard let domainString = decodedUrl.host,
                let domainName = try? DomainName(input: domainString) else {
            return nil
        }
        self.urlInfo = URLInfo(scheme: .https,
                               remainingURLpart: decodedUrl.path,
                               domainName: domainName,
                               ipAddress: nil)
        searchSuggestion = nil
        userSpecifiedTitle = customTitle
        highQualityFaviconImage = image
        self.settings = settings
    }
}

extension Site: Equatable {}
