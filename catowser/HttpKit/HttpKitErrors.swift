//
//  HttpKitErrors.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/12/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

extension HttpKit {
    public enum HttpError: LocalizedError, Equatable {
        /* Comon errors related to http client */
        
        case zombieSelf
        case swiftVersionIsTooLowForAsyncAwait
        case failedConstructUrl
        case noAuthenticationToken
        case failedConstructRequestParameters
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
            default:
                return "\(self)"
            }
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.zombieSelf, .zombieSelf),
                (.swiftVersionIsTooLowForAsyncAwait, .swiftVersionIsTooLowForAsyncAwait),
                (.failedConstructUrl, .failedConstructUrl),
                (.noAuthenticationToken, .noAuthenticationToken),
                (.failedConstructRequestParameters, .failedConstructRequestParameters),
                (.failedEncodeEncodable, .failedEncodeEncodable),
                (.noInternetConnectionWithHost, .noInternetConnectionWithHost),
                (.noHttpResponse, .noHttpResponse),
                (.notHttpUrlResponse, .notHttpUrlResponse),
                (.invalidURL, .invalidURL),
                (.noHostInUrl, .noHostInUrl),
                (.emptyQueryParam, .emptyQueryParam),
                (.spacesInQueryParam, .spacesInQueryParam):
                return true
            case (let .httpFailure(_), let .httpFailure(_)):
                // return lErr == rErr
                return true
            case (let .jsonSerialization(_), let .jsonSerialization(_)):
                // return lErr == rErr
                return true
            case (let .jsonDecoding(_), let .jsonDecoding(_)):
                // return lErr == rErr
                return true
            case (let .missingRequestParameters(lStr), let .missingRequestParameters(rStr)):
                return lStr == rStr
            default:
                return false
            }
        }
    }
}
