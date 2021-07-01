//
//  HttpKitHeaders.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/12/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

extension HttpKit {
    public enum HttpHeader {
        case contentType(ContentType)
        case contentLength(Int)
        case accept(ContentType)
        case authorization(token: String)
        
        var key: String {
            switch self {
            case .contentType:
                return "Content-Type"
            case .contentLength:
                return "Content-Length"
            case .accept:
                return "Accept"
            case .authorization:
                return "Authorization"
            }
        }
        
        var value: String {
            switch self {
            case .contentType(let type):
                return type.rawValue
            case .contentLength(let length):
                return "\(length)"
            case .accept(let type):
                return type.rawValue
            case .authorization(token: let token):
                // setup different ways for authorization, not only Bearer
                return "Bearer \(token)"
            }
        }
    }
    
    public enum ContentType: String {
        case json = "application/json"
        /// The following type is used to indicate that the response will contain search suggestions.
        /// Link: [doc](http://www.opensearch.org/Specifications/OpenSearch/Extensions/Suggestions/1.0)
        case jsonSuggestions = "application/x-suggestions+json"
        case url = "application/x-www-form-urlencoded"
        case html = "text/html"
    }
}

extension Array where Element == HttpKit.HttpHeader {
    var dictionary: [String: String] {
        var dictionary = [String: String]()
        for header in self {
            dictionary[header.key] = header.value
        }
        return dictionary
    }
}
