//
//  DuckDuckGoAutoCompleteEndpoint.swift
//  BrowserNetworking
//
//  Created by Andrey Ermoshin on 19.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import HttpKit
import Combine
import ReactiveSwift
import CoreHttpKit

public typealias DDGoSuggestionsClient = HttpKit.Client<DuckDuckGoServer,
                                                        AlamofireReachabilityAdaptee<DuckDuckGoServer>>
typealias DDGoSuggestionsEndpoint = Endpoint<DuckDuckGoServer>

extension Endpoint where S == DuckDuckGoServer {
    static func duckduckgoSuggestions(query: String) throws -> DDGoSuggestionsEndpoint {
        guard !query.isEmpty else {
            throw HttpKit.HttpError.emptyQueryParam
        }
        
        let withoutSpaces = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !withoutSpaces.isEmpty else {
            throw HttpKit.HttpError.spacesInQueryParam
        }
        
        let items: [URLQueryItem] = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "list")
        ]
        let headers: [HTTPHeader] = [.ContentType(type: .jsonsuggestions), .Accept(type: .jsonsuggestions)]
        
        return DDGoSuggestionsEndpoint(httpMethod: .get,
                                       path: "ac",
                                       headers: Set(headers),
                                       encodingMethod: .QueryString(items: items.kotlinArray))
    }
}

public struct DDGoSuggestionsResponse: ResponseType {
    public static var successCodes: [Int] {
        [200]
    }
    
    public let queryText: String
    public let textResults: [String]
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        queryText = try container.decode(String.self)
        textResults = try container.decode([String].self)
    }
}

public typealias DDGoRxSignal = Signal<DDGoSuggestionsResponse, HttpKit.HttpError>.Observer
public typealias DDGoRxInterface = HttpKit.RxObserverWrapper<DDGoSuggestionsResponse,
                                                             DuckDuckGoServer,
                                                             DDGoRxSignal>
public typealias DDGoSuggestionsClientRxSubscriber = HttpKit.RxSubscriber<DDGoSuggestionsResponse,
                                                                          DuckDuckGoServer,
                                                                          DDGoRxInterface>
public typealias DDGoSuggestionsProducer = SignalProducer<DDGoSuggestionsResponse, HttpKit.HttpError>
public typealias DDGoSuggestionsClientSubscriber = HttpKit.Subscriber<DDGoSuggestionsResponse,
                                                                      DuckDuckGoServer>
public typealias DDGoSuggestionsPublisher = AnyPublisher<DDGoSuggestionsResponse, HttpKit.HttpError>

extension HttpKit.Client where Server == DuckDuckGoServer {
    public func duckDuckGoSuggestions(for text: String,
                                      subscriber: DDGoSuggestionsClientRxSubscriber) -> DDGoSuggestionsProducer {
        let endpoint: DDGoSuggestionsEndpoint
        do {
            endpoint = try .duckduckgoSuggestions(query: text)
        } catch let error as HttpKit.HttpError {
            return DDGoSuggestionsProducer.init(error: error)
        } catch {
            return DDGoSuggestionsProducer.init(error: .failedConstructRequestParameters)
        }
        
        let adapter: AlamofireHTTPRxAdaptee<DDGoSuggestionsResponse,
                                            DuckDuckGoServer,
                                            DDGoRxInterface> = .init(.waitsForRxObserver)
        let producer = self.rxMakePublicRequest(for: endpoint, transport: adapter, subscriber: subscriber)
        return producer
    }
    
    public func cDuckDuckgoSuggestions(for text: String,
                                       subscriber: DDGoSuggestionsClientSubscriber) -> DDGoSuggestionsPublisher {
        let endpoint: DDGoSuggestionsEndpoint
        do {
            endpoint = try .duckduckgoSuggestions(query: text)
        } catch let error as HttpKit.HttpError {
            return DDGoSuggestionsPublisher(Future.failure(error))
        } catch {
            return DDGoSuggestionsPublisher(Future.failure(.failedConstructRequestParameters))
        }
        
        let adapter: AlamofireHTTPAdaptee<DDGoSuggestionsResponse, DuckDuckGoServer> = .init(.waitsForCombinePromise)
        let future = self.cMakePublicRequest(for: endpoint, transport: adapter, subscriber: subscriber)
        return future.eraseToAnyPublisher()
    }
}
