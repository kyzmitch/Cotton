//
//  GoogleSearchEndpoint.swift
//  BrowserNetworking
//
//  Created by Andrei Ermoshin on 10/12/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import HttpKit
import CoreHttpKit
import ReactiveHttpKit
import ReactiveSwift
#if canImport(Combine)
import Combine
#endif

public typealias GoogleSuggestionsClient = HttpKit.Client<GoogleServer, AlamofireReachabilityAdaptee<GoogleServer>>
typealias GSearchEndpoint = Endpoint<GoogleServer>
public typealias GSearchRxSignal = Signal<GSearchSuggestionsResponse, HttpKit.HttpError>.Observer
public typealias GSearchRxInterface = HttpKit.RxObserverWrapper<GSearchSuggestionsResponse,
                                                                    GoogleServer,
                                                                    GSearchRxSignal>
public typealias GSearchClientRxSubscriber = HttpKit.RxSubscriber<GSearchSuggestionsResponse,
                                                                  GoogleServer,
                                                                  GSearchRxInterface>
public typealias GSearchClientSubscriber = HttpKit.Subscriber<GSearchSuggestionsResponse,
                                                              GoogleServer>
public typealias GSearchProducer = SignalProducer<GSearchSuggestionsResponse, HttpKit.HttpError>
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public typealias CGSearchPublisher = AnyPublisher<GSearchSuggestionsResponse, HttpKit.HttpError>

extension Endpoint where S == GoogleServer {
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
        let headers: [HTTPHeader] = [.ContentType(type: .jsonsuggestions), .Accept(type: .jsonsuggestions)]
        
        let frozenEndpoint = GSearchEndpoint(
            httpMethod: .get,
            path: "complete/search",
            headers: Set(headers),
            encodingMethod: .QueryString(items: items.kotlinArray))
        return frozenEndpoint
    }
}

public final class GSearchSuggestionsResponse: ResponseType {
    static public var successCodes: [Int] {
        [200]
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
    
    public init(_ text: String, _ results: [String]) {
        queryText = text
        textResults = results
    }
}

extension HttpKit.Client where Server == GoogleServer {
    public func googleSearchSuggestions(for text: String, _ subscriber: GSearchClientRxSubscriber) -> GSearchProducer {
        let endpoint: GSearchEndpoint
        do {
            endpoint = try .googleSearchSuggestions(query: text)
        } catch let error as HttpKit.HttpError {
            return GSearchProducer.init(error: error)
        } catch {
            return GSearchProducer.init(error: .failedConstructRequestParameters)
        }
        
        let adapter: AlamofireHTTPRxAdaptee<GSearchSuggestionsResponse,
                                            GoogleServer,
                                            GSearchRxInterface> = .init(.waitsForRxObserver)
        let producer = self.rxMakePublicRequest(for: endpoint, transport: adapter, subscriber: subscriber)
        return producer
    }
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func cGoogleSearchSuggestions(for text: String, _ subscriber: GSearchClientSubscriber) -> CGSearchPublisher {
        let endpoint: GSearchEndpoint
        do {
            endpoint = try .googleSearchSuggestions(query: text)
        } catch let error as HttpKit.HttpError {
            return CGSearchPublisher(Future.failure(error))
        } catch {
            return CGSearchPublisher(Future.failure(.failedConstructRequestParameters))
        }
        
        let adapter: AlamofireHTTPAdaptee<GSearchSuggestionsResponse, GoogleServer> = .init(.waitsForCombinePromise)
        let future = self.cMakePublicRequest(for: endpoint, transport: adapter, subscriber: subscriber)
        return future.eraseToAnyPublisher()
    }
}
