//
//  SearchSuggestionsViewModelImpl.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/22/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import ReactiveSwift
import Combine
import FeaturesFlagsKit
import CoreBrowser

final class SearchSuggestionsViewModelImpl<Strategy> where Strategy: SearchAutocompleteStrategy {
    private let autocomplete: WebSearchAutocomplete<Strategy>
    
    let rxState: MutableProperty<SearchSuggestionsViewState> = .init(.waitingForQuery)
    
    let combineState: CurrentValueSubject<SearchSuggestionsViewState, Never> = .init(.waitingForQuery)
    
    private var searchSuggestionsDisposable: Disposable?
    @available(iOS 13.0, *)
    private lazy var searchSuggestionsCancellable: AnyCancellable? = nil
    
    var state: SearchSuggestionsViewState = .waitingForQuery
    
    init(_ strategy: Strategy) {
        autocomplete = .init(strategy)
    }
    
    deinit {
        if #available(iOS 13.0, *) {
            searchSuggestionsCancellable?.cancel()
        } else {
            searchSuggestionsDisposable?.dispose()
        }
    }
}

extension SearchSuggestionsViewModelImpl: SearchSuggestionsViewModel {
    func fetchSuggestions(_ query: String) {
        let domainNames = InMemoryDomainSearchProvider.shared.domainNames(whereURLContains: query)
        
        let apiType = FeatureManager.appAsyncApiTypeValue()
        switch apiType {
        case .reactive:
            rxState.value = .knownDomainsLoaded(domainNames)
            searchSuggestionsDisposable?.dispose()
            searchSuggestionsDisposable = autocomplete.rxFetchSuggestions(query).startWithResult({ [weak self] result in
                switch result {
                case .success(let suggestions):
                    self?.rxState.value = .everythingLoaded(domainNames, suggestions)
                case .failure(let error):
                    print("Fail to fetch search suggestions: \(error.localizedDescription)")
                }
            })
        case .combine:
            combineState.value = .knownDomainsLoaded(domainNames)
            searchSuggestionsCancellable?.cancel()
            searchSuggestionsCancellable = autocomplete.combineFetchSuggestions(query)
                .catch({ (error) -> Just<[String]> in
                    print("Fail to fetch search suggestions: \(error.localizedDescription)")
                    return .init([])
                })
                .sink(receiveCompletion: { _ in
                    print("Search suggestions request completed")
                }, receiveValue: { [weak self] suggestions in
                    self?.combineState.value = .everythingLoaded(domainNames, suggestions)
                })
        case .asyncAwait:
            break
        }
    }
}
