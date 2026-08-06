//
//  SearchSuggestionsAction.swift
//  CottonViewModels
//
//  Copyright © 2026 Cotton (Catowser). All rights reserved.
//

import ViewModelKit

/// Actions for SearchSuggestions domain state transitions.
public enum SearchSuggestionsAction: ViewModelAction {
    /// Load locally known domains for `query` → `.knownDomainsLoaded`.
    case loadKnownDomains(String)
    /// Load remote autocomplete for `query` from a known-domains-bearing state → `.everythingLoaded`.
    case loadSuggestions(String)

    /// Representative cases for `ViewModelAction` / `CaseIterable`.
    public static var allCases: [SearchSuggestionsAction] {
        [
            .loadKnownDomains(""),
            .loadSuggestions("")
        ]
    }
}
