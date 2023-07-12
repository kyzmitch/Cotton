//
//  HttpKotlinTypes+Extensions.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 4/17/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CottonBase
import Combine

extension Set where Element == CottonBase.HTTPHeader {
    var dictionary: [String: String] {
        var dictionary = [String: String]()
        for header in self {
            dictionary[header.key] = header.value
        }
        return dictionary
    }
}

extension HTTPRequestInfo {
    var urlRequest: URLRequest? {
        guard let url = URL(string: rawURL) else {
            return nil
        }
        
        let portedTimeoutValue = TimeInterval(requestTimeout)
        
        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: portedTimeoutValue)
        request.httpMethod = method.stringValue
        request.allHTTPHeaderFields = headers.dictionary
        
        guard let encodedData = httpBody else {
            return request
        }
        request.httpBody = ByteArrayNativeUtils.companion.convertBytes(byteArray: encodedData)
        return request
    }
}

extension KotlinArray where T == URLQueryPair {
    static var empty: KotlinArray {
        return .init(size: 0) { _ in
            return nil
        }
    }
}
