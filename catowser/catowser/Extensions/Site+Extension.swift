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
import HttpKit

/// Client side extension for `CoreBrowser` `Site` type to be able to detect DoH usage
/// and hide real domain name for favicon http requests.
extension Site {
    /// Provides only local cached URL for favicon, nil if ipAddress is nil.
    var faviconURL: URL? {
        if FeatureManager.boolValue(of: .dnsOverHTTPSAvailable) {
            return URL(faviconIPInfo: url)
        } else {
            return URL(faviconHost: url.host)
        }
    }
    
    /// Attempts resolve domain name from site url before using it in favicon URL.
    ///
    /// - Parameters:
    ///   - policy:        The `SecPolicy` used to evaluate `self`.
    ///   - errorProducer: The closure used transform the failed `OSStatus` and `SecTrustResultType`.
    /// - Throws:          Any `Error` from applying the `policy`, or the result of `errorProducer` if validation fails.
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func fetchFaviconURL(_ resolve: Bool) -> AnyPublisher<URL, Error> {
        typealias URLResult = Result<URL, Error>
        
        guard resolve else {
            let domainURL = URL(faviconHost: url.host)
            // swiftlint:disable:next force_unwrapping
            let result: URLResult = domainURL != nil ? .success(domainURL!) : .failure(HttpKit.HttpError.invalidURL)
            return URLResult.Publisher(result).eraseToAnyPublisher()
        }
        
        guard let faviconDomainURL = URL(faviconHost: url.host) else {
            return URLResult.Publisher(.failure(HttpKit.HttpError.invalidURL)).eraseToAnyPublisher()
        }
        return GoogleDnsClient.shared.resolvedDomainName(in: faviconDomainURL)
            .mapError { (dnsError) -> Error in
                return dnsError
            }.eraseToAnyPublisher()
    }
}
