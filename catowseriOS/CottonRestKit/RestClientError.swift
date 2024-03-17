//
//  RestClientError.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/12/19.
//  Copyright © 2019 Cotton (former Catowser). All rights reserved.
//

import Foundation
import CottonBase

public enum HttpError: LocalizedError, Equatable {
    /* Comon errors related to http client */

    case zombieSelf
    case swiftVersionIsTooLowForAsyncAwait
    case noAuthenticationToken
    case failedConstructRequestParameters
    case invalidDomainName(error: DomainName.Error)
    case failedKotlinRequestConstruct
    case failedEncodeEncodable
    case noInternetConnectionWithHost
    case noHttpResponse
    case notHttpUrlResponse
    case invalidURL
    case notGoodStatusCode(Int)
    case noHostInUrl

    /* Errors specific to endpoints */

    case emptyQueryParam
    case spacesInQueryParam

    case httpFailure(error: Error)
    case jsonSerialization(error: Error)
    case jsonDecoding(error: Error)
    /// can add String assiciated value for missed params
    case missingRequestParameters(String)

    public var localizedDescription: String {
        switch self {
        case .httpFailure(error: let error):
            return "http failure: \(error.localizedDescription)"
        case .jsonSerialization(error: let error):
            return "json serialization: \(error.localizedDescription)"
        case .jsonDecoding(error: let error):
            return "json decoding: \(error.localizedDescription)"
        case .missingRequestParameters(let message):
            return "missing parameters: \(message)"
        case .notGoodStatusCode(let statusCode):
            return "not valid http response status code: \(statusCode)"
        case .invalidDomainName(error: let error):
            return "invalid domain name: \(error.message ?? "no message")"
        default:
            return "\(self)"
        }
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.zombieSelf, .zombieSelf),
             (.swiftVersionIsTooLowForAsyncAwait, .swiftVersionIsTooLowForAsyncAwait),
             (.noAuthenticationToken, .noAuthenticationToken),
             (.failedConstructRequestParameters, .failedConstructRequestParameters),
             (.failedKotlinRequestConstruct, .failedKotlinRequestConstruct),
             (.failedEncodeEncodable, .failedEncodeEncodable),
             (.noInternetConnectionWithHost, .noInternetConnectionWithHost),
             (.noHttpResponse, .noHttpResponse),
             (.notHttpUrlResponse, .notHttpUrlResponse),
             (.invalidURL, .invalidURL),
             (.noHostInUrl, .noHostInUrl),
             (.emptyQueryParam, .emptyQueryParam),
             (.spacesInQueryParam, .spacesInQueryParam):
            return true
        case (let .httpFailure(lhs), let .httpFailure(rhs)):
            guard type(of: lhs) == type(of: rhs) else { return false }
            let error1 = lhs as NSError
            let error2 = rhs as NSError
            return error1.domain == error2.domain && error1.code == error2.code && "\(lhs)" == "\(rhs)"
        case (let .jsonSerialization(lhs), let .jsonSerialization(rhs)):
            guard type(of: lhs) == type(of: rhs) else { return false }
            let error1 = lhs as NSError
            let error2 = rhs as NSError
            return error1.domain == error2.domain && error1.code == error2.code && "\(lhs)" == "\(rhs)"
        case (let .jsonDecoding(lhs), let .jsonDecoding(rhs)):
            guard type(of: lhs) == type(of: rhs) else { return false }
            let error1 = lhs as NSError
            let error2 = rhs as NSError
            return error1.domain == error2.domain && error1.code == error2.code && "\(lhs)" == "\(rhs)"
        case (let .missingRequestParameters(lStr), let .missingRequestParameters(rStr)):
            return lStr == rStr
        case (let .invalidDomainName(error: lhs), let .invalidDomainName(error: rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}
