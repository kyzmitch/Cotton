//
//  HttpClient+AsyncAwait.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 6/10/21.
//  Copyright © 2021 andreiermoshin. All rights reserved.
//

#if swift(>=5.5)

import Foundation
#if canImport(_Concurrency)
// this won't be needed after Swift 5.5 will be released
import _Concurrency
#endif

// Swift Concurrency requires a deployment target of macOS 12, iOS 15, tvOS 15, and watchOS 8 or newer. (70738378)
// source: https://developer.apple.com/documentation/xcode-release-notes/xcode-13-beta-release-notes

extension HttpKit.Client {
    @available(swift 5.5)
    @available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    private func aaMakeRequest<T: ResponseType>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                withAccessToken accessToken: String?,
                                                responseType: T.Type) async throws -> T {
        guard let url = endpoint.url(relatedTo: self.server) else {
            throw HttpKit.HttpError.failedConstructUrl
        }
        var httpRequest = URLRequest(url: url,
                                     cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                     timeoutInterval: self.httpTimeout)
        httpRequest.httpMethod = endpoint.method.rawValue
        httpRequest.allHTTPHeaderFields = endpoint.headers?.dictionary
        if let token = accessToken {
            let auth: HttpKit.HttpHeader = .authorization(token: token)
            httpRequest.setValue(auth.value, forHTTPHeaderField: auth.key)
        }
        
        do {
            try httpRequest.addParameters(from: endpoint)
        } catch let error as HttpKit.HttpError {
            throw error
        } catch {
            throw HttpKit.HttpError.httpFailure(error: error, request: httpRequest)
        }
        
        let codes = T.successCodes
        let (data, response) = await try urlSession.data(for: httpRequest, delegate: self.sessionTaskHandler)
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
    public func aaMakePublicRequest<T: ResponseType>(for endpoint: HttpKit.Endpoint<T, Server>,
                                              responseType: T.Type) async throws -> T {
        let value = await try aaMakeRequest(for: endpoint,
                                               withAccessToken: nil,
                                               responseType: responseType)
        return value
    }
    
    @available(swift 5.5)
    @available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func aaMakeAuthorizedRequest<T: ResponseType>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                  withAccessToken accessToken: String,
                                                  responseType: T.Type) async throws -> T {
        let value = await try aaMakeRequest(for: endpoint,
                                               withAccessToken: accessToken,
                                               responseType: responseType)
        return value
    }
}

#endif
