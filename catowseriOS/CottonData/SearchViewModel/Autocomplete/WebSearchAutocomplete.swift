//
//  WebSearchAutocomplete.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/21/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import ReactiveSwift
import Combine
import CottonRestKit

private extension String {
    static let waitingQueueName: String = .queueNameWith(suffix: "searchThrottle")
}

typealias WebSearchSuggestionsProducer = SignalProducer<[String], HttpError>
typealias WebSearchSuggestionsPublisher = AnyPublisher<[String], HttpError>

/// Web search suggestions (search autocomplete) facade
final class WebSearchAutocomplete<Strategy> where Strategy: SearchAutocompleteStrategy {
    let strategy: Strategy
    
    private lazy var waitingQueue = DispatchQueue(label: .waitingQueueName)
    private lazy var waitingScheduler = QueueScheduler(qos: .userInitiated,
                                                       name: .waitingQueueName,
                                                       targeting: waitingQueue)
    
    init(_ strategy: Strategy) {
        self.strategy = strategy
    }
    
    func rxFetchSuggestions(_ query: String) -> WebSearchSuggestionsProducer {
        let source = SignalProducer<String, Never>.init(value: query)
        return source
            .delay(0.5, on: waitingScheduler)
            .flatMap(.latest, { [weak self] _ -> WebSearchSuggestionsProducer in
                guard let self = self else {
                    return .init(error: .zombieSelf)
                }
                return self.strategy.suggestionsProducer(for: query)
                    .map { $0.textResults }
            })
            .observe(on: QueueScheduler.main)
    }
    
    func combineFetchSuggestions(_ query: String) -> WebSearchSuggestionsPublisher {
        let source = Just<String>(query)
        return source
            .delay(for: 0.5, scheduler: waitingQueue)
            .mapError({ (_) -> HttpError in
                // workaround to be able to compile case when `Just` has no error type for Failure
                // but it is required to be able to use `flatMap` in next call
                // another option is to use custom publisher which supports non Never Failure type
                return .zombieSelf
            })
            .flatMap({ [weak self] _ -> WebSearchSuggestionsPublisher in
                guard let self = self else {
                    typealias SuggestionsResult = Result<[String], HttpError>
                    let errorResult: SuggestionsResult = .failure(.zombieSelf)
                    return errorResult.publisher.eraseToAnyPublisher()
                }
                return self.strategy.suggestionsPublisher(for: query)
                    .map { $0.textResults }
                    .eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
