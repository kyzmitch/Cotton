//
//  SearchSuggestionsViewModel.swift
//  CottonViewModels
//
//  Created by Andrei Ermoshin on 6/21/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import ViewModelKit

/// Kit-backed SearchSuggestions view model.
public typealias SearchSuggestionsViewModel = BaseViewModel<
    SearchSuggestionsViewState<SearchSuggestionsStateContextProxy>,
    SearchSuggestionsAction,
    SearchSuggestionsStateContextProxy
>

extension SearchSuggestionsViewModel {
    /// Sequences kit actions so observers see `.knownDomainsLoaded` before `.everythingLoaded`.
    ///
    /// Only calls `sendAction`; does not mutate published state directly.
    public func fetchSuggestions(_ query: String) async {
        do {
            try await sendAction(.loadKnownDomains(query))
            try Task.checkCancellation()
            try await sendAction(.loadSuggestions(query))
        } catch is CancellationError {
            return
        } catch {
            return
        }
    }
}
