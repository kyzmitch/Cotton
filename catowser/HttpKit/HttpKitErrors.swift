//
//  HttpKitErrors.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/12/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

extension HttpKit {
    public enum HttpError: Swift.Error {
        /* Comon errprs related to http client */
        
        case zombySelf
        case failedConstructUrl
        
        case httpFailure(error: Error)
        case jsonSerialization(error: Error)
        case jsonDecoding(error: Error)
        /// can add String assiciated vakue for missed params
        case missingRequestParameters
        case noAuthenticationToken
        case failedConstructRequestParameters
        case failedEncodeJSONRequestParameters
        case failedEncodeEncodable
        case noInternetConnectionWithHost
        case noHttpResponse
        
        var localizedDescription: String {
            switch self {
            case .httpFailure(error: let error):
                return "http failure: \(error.localizedDescription)"
            case .jsonSerialization(error: let error):
                return "json serialization: \(error.localizedDescription)"
            case .jsonDecoding(error: let error):
                return "json decoding: \(error.localizedDescription)"
            default:
                return "\(self)"
            }
        }
        
    }
}
