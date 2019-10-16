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

fileprivate extension HttpKit.Endpoint {
    var successResponseCodes: [Int] {
        return [200]
    }
}

extension HttpKit.Endpoint {
    static func googleSearchSuggestions(query: String) throws -> HttpKit.GSearchEndpoint {
        let items: [URLQueryItem] = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "client", value: "firefox")
        ]
        // Actually it's possible to get correct response even without any headers
        let headers: [HttpKit.HttpHeader] = [.contentType(.jsonSuggestions),
                                             .accept(.jsonSuggestions)]
        
        return HttpKit.GSearchEndpoint(method: .get,
                                       path: "complete/search",
                                       queryItems: items,
                                       headers: headers,
                                       encodingMethod: .queryString)
    }
}

extension HttpKit {
    public struct GoogleSearchSuggestionsResponse: Decodable {
        /*
         ["test",["test","testrail","test drive unlimited 2","test drive unlimited","testometrika","testlink","testdisk","test yourself","tests lunn","testflight"]]
         */
        let queryText: String
        let textResults: [String]
        
        public init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            let array = try container.decode([String, [String]].self)
            
        }
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
        
        print("Prove for extension: \(endpoint.successResponseCodes)")
        let producer = self.makePublicRequest(for: endpoint, responseType: endpoint.responseType)
        return producer
    }
}
