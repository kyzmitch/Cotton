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
    let autocomplete: WebSearchAutocomplete<Strategy>
    
    let rxState: MutableProperty<SearchSuggestionsViewState> = .init(.waitingForQuery)
    
    let combineState: CurrentValueSubject<SearchSuggestionsViewState, Never> = .init(.waitingForQuery)
    
    /// Using `Published` property wrapper from not related SwiftUI for now
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    @Published var state: SearchSuggestionsViewState = .waitingForQuery
    
    /// This is a replacement for `Task.Handler`, property wrapper can't be defined in protocol
    var statePublisher: Published<SearchSuggestionsViewState>.Publisher { $state }
    
    private var searchSuggestionsDisposable: Disposable?
    
    @available(iOS 13.0, *)
    private lazy var searchSuggestionsCancellable: AnyCancellable? = nil
    
#if swift(>=5.5)
    @available(swift 5.5)
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    lazy var searchSuggestionsTaskHandler: Task<[String], Error>? = nil
#endif
    
    init(_ strategy: Strategy) {
        autocomplete = .init(strategy)
    }
    
    deinit {
        searchSuggestionsCancellable?.cancel()
        searchSuggestionsDisposable?.dispose()
        searchSuggestionsTaskHandler?.cancel()
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
            if #available(iOS 15.0, *) {
#if swift(>=5.5)
                state = .knownDomainsLoaded(domainNames)
                searchSuggestionsTaskHandler?.cancel()
                Task {
                    await aaFetchSuggestions(query, domainNames)
                }
#else
                assertionFailure("Swift version isn't 5.5")
#endif
            } else {
                assertionFailure("iOS version is not >= 15.x")
            }
        }
    }
}
