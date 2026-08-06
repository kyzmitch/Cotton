//
//  SearchAutocompleteStrategy.swift
//  CottonDataServices
//
//  Created by Andrei Ermoshin on 6/21/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation
import CottonRestKit
@preconcurrency import ReactiveSwift
import Combine

/// Search auto complete strategy
public protocol SearchAutocompleteStrategy: AnyObject, Sendable {
    func suggestionsProducer(for text: String) -> SignalProducer<SearchSuggestionsResponse, HttpError>
    func suggestionsPublisher(for text: String) -> AnyPublisher<SearchSuggestionsResponse, HttpError>
    @available(swift 5.5)
    @available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func suggestionsTask(for text: String) async throws -> SearchSuggestionsResponse
}
