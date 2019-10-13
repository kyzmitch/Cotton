//
//  GoogleSearchEndpoint.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/12/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import ReactiveSwift

extension HttpKit {
    typealias GSearchEndpoint = HttpKit.Endpoint<HttpKit.GoogleSearchSuggestionsResponse, HttpKit.GoogleServer>
    public typealias GSearchProducer = SignalProducer<HttpKit.GoogleSearchSuggestionsResponse, HttpKit.HttpError>
}

extension HttpKit.Endpoint {
    static func googleSearchSuggestions(query: String) throws -> HttpKit.GSearchEndpoint {
        let items: [URLQueryItem] = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "client", value: "firefox")
        ]
        return HttpKit.GSearchEndpoint(method: .get,
                                       path: "complete/search",
                                       queryItems: items,
                                       headers: nil,
                                       encodingMethod: .queryString)
    }
}

extension HttpKit {
    public struct GoogleSearchSuggestionsResponse: Decodable {
        
    }
}

extension HttpKit.Client where Server == HttpKit.GoogleServer {
    public func searchSuggestions(for text: String) -> HttpKit.GSearchProducer {
        let endpoint: HttpKit.GSearchEndpoint
        do {
            endpoint = try .googleSearchSuggestions(query: text)
        } catch {
            return HttpKit.GSearchProducer.init(error: .failedConstructRequestParameters)
        }
        
        let producer = self.makePublicRequest(for: endpoint, responseType: endpoint.responseType)
        return producer
    }
}
