//
//  HttpClient+Kotlin.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 4/16/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CoreHttpKit

extension HttpKit.Client {
    public func kMakeRequest<T, B: HTTPAdapter>(for endpoint: Endpoint<T, Server>,
                                                withAccessToken accessToken: String?,
                                                transport adapter: B) where B.Response == T, B.Server == Server {
        let requestInfo = endpoint.request(server: server,
                                           requestTimeout: Int64(httpTimeout),
                                           accessToken: accessToken)
        guard let httpRequest = requestInfo.urlRequest else {
            let result: HttpTypedResult<T> = .failure(.failedKotlinRequestConstruct)
            adapter.wrapperHandler()(result)
            return
        }
        let codes = T.successCodes
        adapter.performRequest(httpRequest, sucessCodes: codes)
    }
}

private extension Set where Element == CoreHttpKit.HTTPHeader {
    var dictionary: [String: String] {
        var dictionary = [String: String]()
        for header in self {
            dictionary[header.key] = header.value
        }
        return dictionary
    }
}

private extension HTTPRequestInfo {
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
        request.httpBody = ByteArrayNativeUtils.companion.convert(byteArray: encodedData)
        return request
    }
}
