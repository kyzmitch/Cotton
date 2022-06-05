//
//  DDGoAutocompleteStrategy.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/5/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import BrowserNetworking
import ReactiveSwift
import Combine
import HttpKit

final class DDGoContext: SearchAutocompleteContext {
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
    typealias Response = DDGoSuggestionsResponse
    typealias Context = DDGoContext
    
    private let context: DDGoContext
    
    init(_ context: DDGoContext) {
        self.context = context
    }
    
    func suggestionsProducer(for text: String) -> SignalProducer<DDGoSuggestionsResponse, HttpKit.HttpError> {
        context.client.duckDuckGoSuggestions(for: text, subscriber: context.rxSubscriber)
    }
    
    func suggestionsPublisher(for text: String) -> AnyPublisher<DDGoSuggestionsResponse, HttpKit.HttpError> {
        context.client.cDuckDuckgoSuggestions(for: text, subscriber: context.subscriber)
    }
}
