//
//  Endpoint.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/11/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import Alamofire

extension HttpKit {
    struct Endpoint<T: Decodable> {
        let method: HTTPMethod
        let path: String
        let queryItems: [URLQueryItem]
        // let headers: [HttpHeader]?
        
        /// This is needed to associate type of response with endpoint
        let responseType: T.Type = T.self
        let encodingMethod: ParametersEncodingDestination
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
