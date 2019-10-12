//
//  GoogleSearchEndpoint.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/12/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation


extension HttpKit.Endpoint {
    typealias GSearchEndpoint = HttpKit.Endpoint<HttpKit.GoogleSearchResult, HttpKit.GoogleServer>
    static func googleSearch(query: String) throws -> GSearchEndpoint {
        let items: [URLQueryItem] = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "ie", value: "utf-8"),
            URLQueryItem(name: "client", value: "firefox")
        ]
        return GSearchEndpoint(method: .get,
                               path: "search",
                               queryItems: items,
                               headers: nil,
                               encodingMethod: .queryString)
    }
}

extension HttpKit {
    public struct GoogleSearchResult: Decodable {
        
    }
}
