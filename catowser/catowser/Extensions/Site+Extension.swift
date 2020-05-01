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

extension Site {
    var faviconURL: URL? {
        if FeatureManager.boolValue(of: .dnsOverHTTPSAvailable) {
            return URL(faviconIPInfo: url)
        } else {
            return URL(faviconHost: url.host)
        }
    }
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func fetchFaviconURL(_ fetch: Bool) -> AnyPublisher<URL, Error> {
        return Result<URL, Error>.Publisher(.success(url.url)).eraseToAnyPublisher()
    }
}
