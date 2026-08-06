//
//  SearchSuggestionsViewModelImpl.swift
//  CottonViewModels
//
//  Created by Andrei Ermoshin on 6/22/22.
//  Copyright © 2022 Cotton (former Catowser). All rights reserved.
//

import CottonUseCases
import ViewModelKit

final class SearchSuggestionsViewModelImpl: SearchSuggestionsViewModel {
    private let autocompleteUseCase: any FetchAutocompleteSuggestionsUseCase
    private let searchContext: SearchViewContext
    private lazy var proxy = SearchSuggestionsStateContextProxy(subject: self)

    init(
        _ autocompleteUseCase: any FetchAutocompleteSuggestionsUseCase,
        _ context: SearchViewContext
    ) {
        self.autocompleteUseCase = autocompleteUseCase
        self.searchContext = context
        super.init(transitioning: SearchSuggestionsStateTransitioning())
    }

    public override var context: Context? {
        proxy
    }
}

extension SearchSuggestionsViewModelImpl: SearchSuggestionsStateContext {
    public func knownDomains(matching query: String) async -> KnownDomains {
        await searchContext.knownDomainsStorage.domainNames(whereURLContains: query)
    }

    public func autocompleteSuggestions(for query: String) async throws -> QuerySuggestions {
        let source = await searchContext.webAutocompletionSourceValue
        return try await autocompleteUseCase.execute(input: (source, query))
    }
}
