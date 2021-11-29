//
//  GoogleSearchEndpoint.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/12/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import HttpKit
import ReactiveSwift
#if canImport(Combine)
import Combine
#endif

public typealias GoogleSuggestionsClient = HttpKit.Client<GoogleServer>
typealias GSearchEndpoint = HttpKit.Endpoint<GoogleSearchSuggestionsResponse, GoogleServer>
public typealias GSearchProducer = SignalProducer<GoogleSearchSuggestionsResponse, HttpKit.HttpError>
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public typealias CGSearchPublisher = AnyPublisher<GoogleSearchSuggestionsResponse, HttpKit.HttpError>

extension HttpKit.Endpoint {
    static func googleSearchSuggestions(query: String) throws -> GSearchEndpoint {
        guard !query.isEmpty else {
            throw HttpKit.HttpError.emptyQueryParam
        }
        
        let withoutSpaces = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !withoutSpaces.isEmpty else {
            throw HttpKit.HttpError.spacesInQueryParam
        }
        
        let items: [URLQueryItem] = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "client", value: "firefox")
        ]
        // Actually it's possible to get correct response even without any headers
        let headers: [HttpKit.HttpHeader] = [.contentType(.jsonSuggestions),
                                             .accept(.jsonSuggestions)]
        
        return GSearchEndpoint(method: .get,
                                       path: "complete/search",
                                       headers: headers,
                                       encodingMethod: .queryString(queryItems: items))
    }
}

public struct GoogleSearchSuggestionsResponse: ResponseType {
    public static var successCodes: [Int] {
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

extension HttpKit.Client where Server == GoogleServer {
    public func googleSearchSuggestions(for text: String) -> GSearchProducer {
        let endpoint: GSearchEndpoint
        do {
            endpoint = try .googleSearchSuggestions(query: text)
        } catch let error as HttpKit.HttpError {
            return GSearchProducer.init(error: error)
        } catch {
            return GSearchProducer.init(error: .failedConstructRequestParameters)
        }
        
        let producer = self.rxMakePublicRequest(for: endpoint, responseType: endpoint.responseType)
        return producer
    }
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func cGoogleSearchSuggestions(for text: String) -> CGSearchPublisher {
        let endpoint: GSearchEndpoint
        do {
            endpoint = try .googleSearchSuggestions(query: text)
        } catch let error as HttpKit.HttpError {
            return CGSearchPublisher(Future.failure(error))
        } catch {
            return CGSearchPublisher(Future.failure(.failedConstructRequestParameters))
        }
        
        let future = self.cMakePublicRequest(for: endpoint, responseType: endpoint.responseType)
        return future.eraseToAnyPublisher()
    }
}
