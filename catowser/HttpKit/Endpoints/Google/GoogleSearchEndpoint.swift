//
//  GoogleSearchEndpoint.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/12/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import ReactiveSwift
#if canImport(Combine)
import Combine
#endif

extension HttpKit {
    typealias GSearchEndpoint = Endpoint<GoogleSearchSuggestionsResponse, GoogleServer>
    public typealias GSearchProducer = SignalProducer<GoogleSearchSuggestionsResponse, HttpError>
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public typealias CGSearchPublisher = Deferred<Future<GoogleSearchSuggestionsResponse, HttpError>>
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
    public struct GoogleSearchSuggestionsResponse: ResponseType {
        static var successCodes: [Int] {
            return [200]
        }
        
        /*
         ["test",["test","testrail","test drive unlimited 2",
         "test drive unlimited","testometrika","testlink",
         "testdisk","test yourself","tests lunn","testflight"]]
         */
        public let queryText: String
        public let textResults: [String]
        
        public init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            queryText = try container.decode(String.self)
            textResults = try container.decode([String].self)
        }
    }
}

extension HttpKit.Client where Server == HttpKit.GoogleServer {
    public func googleSearchSuggestions(for text: String) -> HttpKit.GSearchProducer {
        let endpoint: HttpKit.GSearchEndpoint
        do {
            endpoint = try .googleSearchSuggestions(query: text)
        } catch let error as HttpKit.HttpError {
            return HttpKit.GSearchProducer.init(error: error)
        } catch {
            return HttpKit.GSearchProducer.init(error: .failedConstructRequestParameters)
        }
        
        let producer = self.makePublicRequest(for: endpoint, responseType: endpoint.responseType)
        return producer
    }
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func cGoogleSearchSuggestions(for text: String) -> HttpKit.CGSearchPublisher {
        let endpoint: HttpKit.GSearchEndpoint
        do {
            endpoint = try .googleSearchSuggestions(query: text)
        } catch let error as HttpKit.HttpError {
            return HttpKit.CGSearchPublisher(.failure(error))
        } catch {
            return HttpKit.CGSearchPublisher(.failure(.failedConstructRequestParameters))
        }
        
        let future = self.cMakePublicRequest(for: endpoint, responseType: endpoint.responseType)
        return future
    }
}
