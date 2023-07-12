//
//  Site+Extension.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/11/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import CoreBrowser
import FeaturesFlagsKit
#if canImport(Combine)
import Combine
#endif
import BrowserNetworking
import CottonBase
import UIKit

/// Client side extension for `CoreBrowser` `Site` type to be able to detect DoH usage
/// and hide real domain name for favicon http requests.
extension Site {
    convenience init?(_ urlString: String,
                      _ customTitle: String? = nil,
                      _ settings: Settings) {
        guard let decodedUrl = URL(string: urlString) else {
            return nil
        }
        guard let urlInfo = URLInfo(decodedUrl) else {
            return nil
        }
        
        self.init(urlInfo: urlInfo,
                  settings: settings,
                  faviconData: nil,
                  searchSuggestion: nil,
                  userSpecifiedTitle: customTitle)
    }

    convenience init?(_ url: URL, _ suggestion: String?, _ settings: Settings) {
        guard let urlInfo = URLInfo(url) else {
            return nil
        }
        self.init(urlInfo: urlInfo,
                  settings: settings,
                  faviconData: nil,
                  searchSuggestion: suggestion,
                  userSpecifiedTitle: nil)
    }
    
    /// Provides only local cached URL for favicon, nil if ipAddress is nil.
    var faviconURL: URL? {
        if FeatureManager.boolValue(of: .dnsOverHTTPSAvailable) {
            return URL(faviconIPInfo: urlInfo)
        } else {
            return URL(string: urlInfo.faviconURLFromDomain)
        }
    }
    
    /// Attempts resolve domain name from site url before using it in favicon URL.
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func fetchFaviconURL(_ resolve: Bool, _ subscriber: GDNSJsonClientSubscriber) -> AnyPublisher<URL, Error> {
        typealias URLResult = Result<URL, Error>
        
        struct InvalidUrlError: Error {}
        
        guard resolve else {
            let domainURL = URL(string: urlInfo.faviconURLFromDomain)
            // swiftlint:disable:next force_unwrapping
            let result: URLResult = domainURL != nil ? .success(domainURL!) : .failure(InvalidUrlError())
            return URLResult.Publisher(result).eraseToAnyPublisher()
        }
        
        guard let faviconDomainURL = URL(string: urlInfo.faviconURLFromDomain) else {
            return URLResult.Publisher(.failure(InvalidUrlError())).eraseToAnyPublisher()
        }
        return GoogleDnsClient.shared.resolvedDomainName(in: faviconDomainURL, subscriber)
            .mapError { (dnsError) -> Error in
                return dnsError
            }.eraseToAnyPublisher()
    }
    
    func withUpdated(_ newSettings: Site.Settings) -> Site {
        // Can't figure out how to pass favicon data again
        return Site(urlInfo: urlInfo,
                    settings: newSettings,
                    faviconData: nil,
                    searchSuggestion: searchSuggestion,
                    userSpecifiedTitle: userSpecifiedTitle)
    }
}

/// Needed for a swiftUI list view to show a list of different sites.
/// `The purpose of Identifiable is to distinguish the identity of an entity from the state of an entity.`
/// https://github.com/apple/swift-evolution/blob/main/proposals/0261-identifiable.md#concrete-conformances
/// So, this shouldn't be similar to Hashable impl and it doesn't require to combine all the properites in one id value.
extension Site: Identifiable {
    public var id: String {
        // So, it is partly depencs on a state
        urlInfo.platformURL.absoluteString
    }
}
