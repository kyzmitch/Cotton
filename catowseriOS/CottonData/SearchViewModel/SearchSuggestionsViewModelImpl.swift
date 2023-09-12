//
//  SearchSuggestionsViewModelImpl.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/22/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import Combine
import FeaturesFlagsKit
import CoreBrowser
import AutoMockable

/// This is only needed now to not have a direct dependency on FutureManager
public protocol SearchViewContext: AutoMockable {
    var appAsyncApiTypeValue: AsyncApiType { get async }
    var knownDomainsStorage: KnownDomainsSource { get }
}

public final class SearchSuggestionsViewModelImpl<Strategy> where Strategy: SearchAutocompleteStrategy {
    /// autocomplete client
    let autocomplete: WebSearchAutocomplete<Strategy>
    /// search view context
    let searchContext: SearchViewContext
    
    // MARK: - state observers
    
    /// Using `Published` property wrapper from not related SwiftUI for now
    @Published public var state: SearchSuggestionsViewState
    /// State publisher
    public var statePublisher: Published<SearchSuggestionsViewState>.Publisher { $state }
    
    // MARK: - cancelation handlers
    
#if swift(>=5.5)
    @available(swift 5.5)
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    lazy var searchSuggestionsTaskHandler: Task<[String], Error>? = nil
#endif
    
    public init(_ strategy: Strategy, _ context: SearchViewContext) {
        state = .waitingForQuery
        autocomplete = .init(strategy)
        searchContext = context
    }
    
    deinit {
        searchSuggestionsTaskHandler?.cancel()
    }
}

extension SearchSuggestionsViewModelImpl: SearchSuggestionsViewModel {
    public func fetchSuggestions(_ query: String) async {
        let domainNames = await searchContext.knownDomainsStorage.domainNames(whereURLContains: query)
        state = .knownDomainsLoaded(domainNames)
        searchSuggestionsTaskHandler?.cancel()
        do {
            let suggestions = try await autocomplete.aaFetchSuggestions(query)
            state = .everythingLoaded(domainNames, suggestions)
        } catch {
            state = .everythingLoaded(domainNames, [])
        }
    }
}
