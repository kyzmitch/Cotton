//
//  AutocompleteWebSearchUseCase.swift
//  CottonData
//
//  Created by Andrey Ermoshin on 27.01.2024.
//  Copyright © 2024 andreiermoshin. All rights reserved.
//

import Foundation
import CoreBrowser
import ReactiveSwift
import Combine
import CottonRestKit

public typealias WebSearchSuggestionsProducer = SignalProducer<[String], HttpError>
public typealias WebSearchSuggestionsPublisher = AnyPublisher<[String], HttpError>

public protocol AutocompleteWebSearchUseCase<Strategy>: BaseUseCase {
    associatedtype Strategy: SearchAutocompleteStrategy
    var strategy: Strategy { get }
    func rxFetchSuggestions(_ query: String) -> WebSearchSuggestionsProducer
    func combineFetchSuggestions(_ query: String) -> WebSearchSuggestionsPublisher
    func aaFetchSuggestions(_ query: String) async throws -> [String]
}
