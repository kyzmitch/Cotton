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

extension HttpKit {
    public struct Endpoint<T: ResponseType, Server: ServerDescription> {
        public let method: HTTPMethod
        public let path: String
        public let headers: [HttpHeader]?
        
        /// This is needed to associate type of response with endpoint
        public let responseType: T.Type = T.self
        /// To link endpoint to specific server, since it doesn't make sense to use endpoint
        /// for different host or something
        public let serverType: Server.Type = Server.self
        public let encodingMethod: ParametersEncodingDestination
        
        public init(method: HTTPMethod,
                    path: String,
                    headers: [HttpHeader]?,
                    encodingMethod: ParametersEncodingDestination) {
            self.method = method
            self.path = path
            self.headers = headers
            self.encodingMethod = encodingMethod
        }
        
        /// Constructs a URL based on endpoint info and host name from provided server.
        ///
        /// - Parameters:
        ///     - server: server should be used from HttpClient inside its makeRequest functions.
        public func url(relatedTo server: Server) -> URL? {
            var components = URLComponents()
            components.scheme = server.scheme.rawValue
            components.host = server.hostString
            components.path = "/\(path)"
            if case let .queryString(queryItems) = encodingMethod {
                components.queryItems = queryItems
            }
            
            let resultURL = components.url
            return resultURL
        }
        
        /// Constructs `URLRequest`
        public func request(_ url: URL, httpTimeout: TimeInterval, accessToken: String? = nil) -> URLRequest {
            var request = URLRequest(url: url,
                                     cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                     timeoutInterval: httpTimeout)
            request.httpMethod = method.rawValue
            request.allHTTPHeaderFields = headers?.dictionary
            if let token = accessToken {
                let auth: HttpHeader = .authorization(token: token)
                request.setValue(auth.value, forHTTPHeaderField: auth.key)
            }
            return request
        }
    }
    
    public enum ParametersEncodingDestination {
        /// Stores URL query items to include them in URL
        case queryString(queryItems: [URLQueryItem])
        /// Http body Dictionary to generate JSON
        case httpBodyJSON(parameters: [String: Any])
        /// Http body data enoded from `Encodable`
        case httpBody(encodedData: Data)
    }
    
    public struct VoidResponse: ResponseType {
        public static var successCodes: [Int] {
            return [200, 201]
        }
    }
    
    public typealias VoidEndpoint<Server: ServerDescription> = Endpoint<VoidResponse, Server>
}

public protocol ResponseType: Decodable {
    static var successCodes: [Int] { get }
}

extension ResponseType {
    static var successCodes: [Int] {
        return [200, 201]
    }
}
