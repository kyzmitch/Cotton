//
//  SearchAutocompleteStrategy.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/21/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import CottonRestKit
import ReactiveSwift
import Combine
import AutoMockable

// swiftlint:disable comment_spacing
//sourcery: associatedtype = "Context: RestClientContext"
public protocol SearchAutocompleteStrategy: AnyObject, AutoMockable {
    // swiftlint:enable comment_spacing
    
    associatedtype Context: RestClientContext
    
    init(_ context: Context)
    func suggestionsProducer(for text: String) -> SignalProducer<SearchSuggestionsResponse, HttpError>
    func suggestionsPublisher(for text: String) -> AnyPublisher<SearchSuggestionsResponse, HttpError>
    @available(swift 5.5)
    @available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func suggestionsTask(for text: String) async throws -> SearchSuggestionsResponse
}
