//
//  AutocompleteSearchUseCase.swift
//  CottonData
//
//  Created by Andrey Ermoshin on 27.01.2024.
//  Copyright © 2024 Cotton (former Catowser). All rights reserved.
//

import Foundation
import CoreBrowser
import ReactiveSwift
import Combine
import CottonRestKit
import AutoMockable

public typealias WebSearchSuggestionsProducer = SignalProducer<[String], HttpError>
public typealias WebSearchSuggestionsPublisher = AnyPublisher<[String], HttpError>

// swiftlint:disable comment_spacing
//sourcery: associatedtype = "Strategy: SearchAutocompleteStrategy"
public protocol AutocompleteSearchUseCase: BaseUseCase, AutoMockable {
    // swiftlint:enable comment_spacing

    associatedtype Strategy: SearchAutocompleteStrategy
    var strategy: Strategy { get }
    func rxFetchSuggestions(_ query: String) -> WebSearchSuggestionsProducer
    func combineFetchSuggestions(_ query: String) -> WebSearchSuggestionsPublisher
    func aaFetchSuggestions(_ query: String) async throws -> [String]
}
