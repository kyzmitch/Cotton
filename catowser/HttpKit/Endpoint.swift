//
//  Endpoint.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/11/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case get
    case post
}

public protocol URLRequestCreatable {
    func convertToURLRequest() throws -> URLRequest
}

extension URLRequest: URLRequestCreatable {
    public func convertToURLRequest() throws -> URLRequest {
        return self
    }
}

/// Interface for some JSON encoder (e.g. Alamofire implementation) to hide it and
/// not use it directly and be able to mock it for unit testing
public protocol JSONRequestEncodable {
    func encodeRequest(_ urlRequest: URLRequestCreatable, with parameters: [String: Any]?) throws -> URLRequest
}

extension HttpKit {
    public struct Endpoint<T: ResponseType, Server: ServerDescription>: Equatable {
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
        
        public static func == (lhs: HttpKit.Endpoint<T, Server>, rhs: HttpKit.Endpoint<T, Server>) -> Bool {
            return lhs.method == rhs.method &&
            lhs.path == rhs.path &&
            lhs.headers == rhs.headers &&
            lhs.responseType == rhs.responseType &&
            lhs.serverType == rhs.serverType &&
            lhs.encodingMethod == rhs.encodingMethod
        }
        
        /// Constructs a URL based on endpoint info and host name from provided server.
        ///
        /// - Parameters:
        ///     - server: server should be used from HttpClient inside its makeRequest functions.
        public func url(relatedTo server: Server) -> URL? {
            var components = URLComponents()
            components.scheme = server.scheme.rawValue.isEmpty ? nil : server.scheme.rawValue
            components.host = server.hostString.isEmpty ? nil : server.hostString
            components.path = "/\(path)"
            if case let .queryString(queryItems) = encodingMethod {
                components.queryItems = queryItems
            }
            
            let resultURL = components.url
            return resultURL
        }
        
        /// Constructs `URLRequest`
        public func request(_ url: URL,
                            httpTimeout: TimeInterval,
                            jsonEncoder: JSONRequestEncodable,
                            accessToken: String? = nil) throws -> URLRequest {
            var request = URLRequest(url: url,
                                     cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                     timeoutInterval: httpTimeout)
            request.httpMethod = method.rawValue
            request.allHTTPHeaderFields = headers?.dictionary
            if let token = accessToken {
                let auth: HttpHeader = .authorization(token: token)
                request.setValue(auth.value, forHTTPHeaderField: auth.key)
            }
            switch encodingMethod {
            case .httpBodyJSON(parameters: let parameters):
                request = try jsonEncoder.encodeRequest(request, with: parameters)
            case .httpBody(encodedData: let encodedData):
                let contentHeader: HttpKit.HttpHeader = .contentType(.json)
                request.setValue(contentHeader.value, forHTTPHeaderField: contentHeader.key)
                request.httpBody = encodedData
            case .queryString:
                let contentHeader: HttpKit.HttpHeader = .contentType(.url)
                request.setValue(contentHeader.value, forHTTPHeaderField: contentHeader.key)
            }
            return request
        }
    }
    
    public enum ParametersEncodingDestination: Equatable {
        /// Stores URL query items to include them in URL
        case queryString(queryItems: [URLQueryItem])
        /// Http body Dictionary to generate JSON
        case httpBodyJSON(parameters: [String: Any])
        /// Http body data enoded from `Encodable`
        case httpBody(encodedData: Data)
        
        public static func == (lhs: HttpKit.ParametersEncodingDestination,
                               rhs: HttpKit.ParametersEncodingDestination) -> Bool {
            switch (lhs, rhs) {
            case (.queryString(queryItems: let lItems), queryString(queryItems: let rItems)):
                return lItems == rItems
            case (.httpBodyJSON(parameters: let lItems), httpBodyJSON(parameters: let rItems)):
                // Not full comparison because values of type `Any` don't confirm to Equatable
                return lItems.keys == rItems.keys
            case (.httpBody(encodedData: let lData), httpBody(encodedData: let rData)):
                return lData == rData
            default:
                return false
            }
        }
    }
    
    /// Non-nominal types cannot be extended.
    /// Void is an empty tuple, and because tuples are non-nominal types,
    /// you can’t add methods or properties or conformance to protocols.
    /// https://nshipster.com/void/
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
