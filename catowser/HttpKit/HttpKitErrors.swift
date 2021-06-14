//
//  HttpKitErrors.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/12/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

extension HttpKit {
    public enum HttpError: LocalizedError {
        /* Comon errors related to http client */
        
        case zombySelf
        case swiftVersionIsTooLowForAsyncAwait
        case failedConstructUrl
        
        case httpFailure(error: Error, request: URLRequest?)
        case jsonSerialization(error: Error)
        case jsonDecoding(error: Error)
        /// can add String assiciated value for missed params
        case missingRequestParameters(String)
        case noAuthenticationToken
        case failedConstructRequestParameters
        case failedEncodeJSONRequestParameters(Error)
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
        
        public var localizedDescription: String {
            switch self {
            case .httpFailure(error: let error, request: _):
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
        
    }
}
