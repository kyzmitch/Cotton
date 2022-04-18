//
//  HttpClient+AsyncAwait.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 6/10/21.
//  Copyright © 2021 andreiermoshin. All rights reserved.
//

#if swift(>=5.5)

import Foundation
import CoreHttpKit

extension HttpKit.Client {
    @available(swift 5.5)
    @available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    // gryphon ignore
    private func aaMakeRequest<T: ResponseType>(for endpoint: Endpoint,
                                                withAccessToken accessToken: String?,
                                                responseType: T.Type) async throws -> T {
        let requestInfo = endpoint.request(server: server,
                                           requestTimeout: Int64(httpTimeout),
                                           accessToken: accessToken)
        guard let httpRequest = requestInfo.urlRequest else {
            throw HttpKit.HttpError.failedKotlinRequestConstruct
        }
        
        let codes = T.successCodes
        // https://developer.apple.com/documentation/foundation/urlsession/3767352-data
        let (data, response) = try await urlSession.data(for: httpRequest, delegate: self.sessionTaskHandler)
        guard let urlResponse = response as? HTTPURLResponse else {
            throw HttpKit.HttpError.notHttpUrlResponse
        }
        guard codes.contains(urlResponse.statusCode) else {
            throw HttpKit.HttpError.notGoodStatusCode(urlResponse.statusCode)
        }
        
        let decodedValue = try JSONDecoder().decode(T.self, from: data)
        return decodedValue
    }
    
    @available(swift 5.5)
    @available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    // gryphon ignore
    public func aaMakePublicRequest<T: ResponseType>(for endpoint: Endpoint,
                                                     responseType: T.Type) async throws -> T {
        let value = try await aaMakeRequest(for: endpoint,
                                            withAccessToken: nil,
                                            responseType: responseType)
        return value
    }
    
    @available(swift 5.5)
    @available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    // gryphon ignore
    func aaMakeAuthorizedRequest<T: ResponseType>(for endpoint: Endpoint,
                                                  withAccessToken accessToken: String,
                                                  responseType: T.Type) async throws -> T {
        let value = try await aaMakeRequest(for: endpoint,
                                            withAccessToken: accessToken,
                                            responseType: responseType)
        return value
    }
}

#endif
