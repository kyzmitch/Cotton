//
//  Endpoint.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/11/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
// Alamofire only needed for `HTTPMethod` type
import Alamofire

protocol EndpointDescription {
    var successResponseCodes: [Int] {get}
}

extension EndpointDescription {
    var successResponseCodes: [Int] {
        return [200, 201]
    }
}

extension HttpKit.Endpoint: EndpointDescription {
}

extension HttpKit {
    struct Endpoint<T: Decodable, Server: ServerDescription> {
        let method: HTTPMethod
        let path: String
        let queryItems: [URLQueryItem]
        let headers: [HttpHeader]?
        
        /// This is needed to associate type of response with endpoint
        let responseType: T.Type = T.self
        /// To link endpoint to specific server, since it doesn't make sense to use endpoint for different host or something
        let serverType: Server.Type = Server.self
        let encodingMethod: ParametersEncodingDestination
        
        /// Constructs a URL based on endpoint info and host name from provided server.
        ///
        /// - Parameters:
        ///     - server: server should be used from HttpClient inside its makeRequest functions.
        func url(_ server: Server) -> URL? {
            var components = URLComponents()
            components.scheme = server.scheme
            components.host = server.hostString
            components.path = "/\(path)"
            components.queryItems = queryItems
            
            let resultURL = components.url
            return resultURL
        }
    }
    
    enum ParametersEncodingDestination {
        case queryString
        case httpBodyJSON(parameters: [String: Any])
        /// Data enoded from `Encodable`
        case httpBody(encodedData: Data)
    }
    
    struct VoidResponse: Decodable {
    }
}
