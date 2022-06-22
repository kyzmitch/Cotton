//
//  SearchSuggestionsViewModel.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/21/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import ReactiveSwift
import Combine

typealias KnownDomains = [String]
typealias QuerySuggestions = [String]

/// View state, without error, because we want to show at least known domains even if there was a network failure
/// Need to return to `waitingForQuery` state after view changes the text
enum SearchSuggestionsViewState {
    case waitingForQuery
    case knownDomainsLoaded(KnownDomains)
    case everythingLoaded(KnownDomains, QuerySuggestions)
}

protocol SearchSuggestionsViewModel: AnyObject {
    /// Initiate fetching only after subscribing to the async interfaces below
    func fetchSuggestions(_ query: String)
    
    var rxState: MutableProperty<SearchSuggestionsViewState> { get }
    var combineState: CurrentValueSubject<SearchSuggestionsViewState, Never> { get }
}
