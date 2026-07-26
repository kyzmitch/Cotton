//
//  MockSearchAutocompleteStrategy.swift
//  CottonSearchTests
//

import Combine
import CottonRestKit
import CottonSearch
import Foundation
@preconcurrency import ReactiveSwift

final class MockSearchAutocompleteStrategy: SearchAutocompleteStrategy, @unchecked Sendable {
    var publisherHandler: ((String) -> AnyPublisher<SearchSuggestionsResponse, HttpError>)?
    private(set) var publisherCalls: [String] = []

    func suggestionsProducer(for text: String) -> SignalProducer<SearchSuggestionsResponse, HttpError> {
        preconditionFailure("MockSearchAutocompleteStrategy.suggestionsProducer should not be called")
    }

    func suggestionsPublisher(for text: String) -> AnyPublisher<SearchSuggestionsResponse, HttpError> {
        publisherCalls.append(text)
        guard let publisherHandler else {
            preconditionFailure("MockSearchAutocompleteStrategy.publisherHandler was not set")
        }
        return publisherHandler(text)
    }

    func suggestionsTask(for text: String) async throws -> SearchSuggestionsResponse {
        preconditionFailure("MockSearchAutocompleteStrategy.suggestionsTask should not be called")
    }
}
