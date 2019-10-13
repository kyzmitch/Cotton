//
//  HttpKitHeaders.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/12/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

extension HttpKit {
    enum HttpHeader {
        case contentType(ContentType)
        case accept(ContentType)
        
        var key: String {
            switch self {
            case .contentType:
                return "Content-Type"
            case .accept:
                return "Accept"
            }
        }
        
        var value: String {
            switch self {
            case .contentType(let type):
                return type.rawValue
            case .accept(let type):
                return type.rawValue
            }
        }
    }
    
    enum ContentType: String {
        case json = "application/json"
        /// The following type is used to indicate that the response will contain search suggestions.
        /// Link: [doc](http://www.opensearch.org/Specifications/OpenSearch/Extensions/Suggestions/1.0)
        case jsonSuggestions = "application/x-suggestions+json"
        case url = "application/x-www-form-urlencoded"
    }
}
