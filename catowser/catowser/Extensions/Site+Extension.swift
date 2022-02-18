//
//  Site+Extension.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/11/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import CoreBrowser
#if canImport(Combine)
import Combine
#endif
import BrowserNetworking

/// Client side extension for `CoreBrowser` `Site` type to be able to detect DoH usage
/// and hide real domain name for favicon http requests.
extension Site {
    /// Provides only local cached URL for favicon, nil if ipAddress is nil.
    var faviconURL: URL? {
        if FeatureManager.boolValue(of: .dnsOverHTTPSAvailable) {
            return URL(faviconIPInfo: urlInfo)
        } else {
            return URL(faviconHost: urlInfo.host)
        }
    }
    
    /// Attempts resolve domain name from site url before using it in favicon URL.
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func fetchFaviconURL(_ resolve: Bool, _ subscriber: GDNSJsonClientSubscriber) -> AnyPublisher<URL, Error> {
        typealias URLResult = Result<URL, Error>
        
        struct InvalidUrlError: Error {}
        
        guard resolve else {
            let domainURL = URL(faviconHost: urlInfo.host)
            // swiftlint:disable:next force_unwrapping
            let result: URLResult = domainURL != nil ? .success(domainURL!) : .failure(InvalidUrlError())
            return URLResult.Publisher(result).eraseToAnyPublisher()
        }
        
        guard let faviconDomainURL = URL(faviconHost: urlInfo.host) else {
            return URLResult.Publisher(.failure(InvalidUrlError())).eraseToAnyPublisher()
        }
        return GoogleDnsClient.shared.resolvedDomainName(in: faviconDomainURL, subscriber)
            .mapError { (dnsError) -> Error in
                return dnsError
            }.eraseToAnyPublisher()
    }
}
