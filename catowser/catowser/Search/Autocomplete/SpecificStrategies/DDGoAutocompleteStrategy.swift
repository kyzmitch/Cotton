//
//  DDGoAutocompleteStrategy.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/21/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import BrowserNetworking
import ReactiveSwift
import Combine
import HttpKit

final class DDGoContext: RestClientContext {
    typealias Response = DDGoSuggestionsResponse
    typealias Server = DuckDuckGoServer
    
    let client: Client
    let rxSubscriber: HttpKitRxSubscriber
    let subscriber: HttpKitSubscriber
    
    init(_ client: Client,
         _ rxSubscriber: HttpKitRxSubscriber,
         _ subscriber: HttpKitSubscriber) {
        self.client = client
        self.rxSubscriber = rxSubscriber
        self.subscriber = subscriber
    }
}

final class DDGoAutocompleteStrategy: SearchAutocompleteStrategy {
    typealias Context = DDGoContext
    
    private let context: Context
    
    init(_ context: Context) {
        self.context = context
    }
    
    func suggestionsProducer(for text: String) -> SignalProducer<SearchSuggestionsResponse, HttpKit.HttpError> {
        context.client.duckDuckGoSuggestions(for: text, subscriber: context.rxSubscriber)
            .map { SearchSuggestionsResponse($0) }
    }
    
    func suggestionsPublisher(for text: String) -> AnyPublisher<SearchSuggestionsResponse, HttpKit.HttpError> {
        context.client.cDuckDuckgoSuggestions(for: text, subscriber: context.subscriber)
            .map { SearchSuggestionsResponse($0) }
            .eraseToAnyPublisher()
    }
    
    @available(swift 5.5)
    @available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func suggestionsTask(for text: String) async throws -> SearchSuggestionsResponse {
        let response = try await context.client.aaDuckDuckGoSuggestions(for: text)
        return SearchSuggestionsResponse(response)
    }
}
