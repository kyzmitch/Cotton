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
import AutoMockable

/// This is only needed now to not have a direct dependency on FutureManager
public protocol SearchViewContext: AutoMockable {
    var appAsyncApiTypeValue: AsyncApiType { get }
    var knownDomainsStorage: KnownDomainsSource { get }
}

public final class SearchSuggestionsViewModelImpl<Strategy> where Strategy: SearchAutocompleteStrategy {
    /// autocomplete client
    let autocomplete: WebSearchAutocomplete<Strategy>
    /// search view context
    let searchContext: SearchViewContext
    
    // MARK: - state observers
    
    public let rxState: MutableProperty<SearchSuggestionsViewState>
    public let combineState: CurrentValueSubject<SearchSuggestionsViewState, Never>
    /// Using `Published` property wrapper from not related SwiftUI for now
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    @Published public var state: SearchSuggestionsViewState
    public var statePublisher: Published<SearchSuggestionsViewState>.Publisher { $state }
    
    // MARK: - cancelation handlers
    
    private var searchSuggestionsDisposable: Disposable?
    @available(iOS 13.0, *)
    private lazy var searchSuggestionsCancellable: AnyCancellable? = nil
    
#if swift(>=5.5)
    @available(swift 5.5)
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    lazy var searchSuggestionsTaskHandler: Task<[String], Error>? = nil
#endif
    
    public init(_ strategy: Strategy, _ context: SearchViewContext) {
        rxState = .init(.waitingForQuery)
        combineState = .init(.waitingForQuery)
        state = .waitingForQuery
        autocomplete = .init(strategy)
        searchContext = context
    }
    
    deinit {
        searchSuggestionsCancellable?.cancel()
        searchSuggestionsDisposable?.dispose()
        searchSuggestionsTaskHandler?.cancel()
    }
}

extension SearchSuggestionsViewModelImpl: SearchSuggestionsViewModel {
    // swiftlint:disable:next function_body_length
    public func fetchSuggestions(_ query: String) {
        let domainNames = searchContext.knownDomainsStorage.domainNames(whereURLContains: query)
        
        let apiType = searchContext.appAsyncApiTypeValue
        switch apiType {
        case .reactive:
            rxState.value = .knownDomainsLoaded(domainNames)
            searchSuggestionsDisposable?.dispose()
            searchSuggestionsDisposable = autocomplete.rxFetchSuggestions(query)
                .flatMapError({ error in
                    print("Fail to fetch search suggestions: \(error.localizedDescription)")
                    return WebSearchSuggestionsProducer(value: [])
                })
                .startWithResult({ [weak self] result in
                    switch result {
                    case .success(let suggestions):
                        self?.rxState.value = .everythingLoaded(domainNames, suggestions)
                    default:
                        break
                }
            })
        case .combine:
            combineState.value = .knownDomainsLoaded(domainNames)
            searchSuggestionsCancellable?.cancel()
            searchSuggestionsCancellable = autocomplete.combineFetchSuggestions(query)
                .catch({ error -> Just<[String]> in
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
                    let suggestions = try await autocomplete.aaFetchSuggestions(query)
                    await MainActor.run {
                        state = .everythingLoaded(domainNames, suggestions)
                    }
                }
#else
                assertionFailure("Swift version isn't 5.5")
#endif
            } else {
                assertionFailure("iOS version is not >= 15.x")
            }
        }
    }
    
    public func aaFetchSuggestions(_ query: String) async -> SearchSuggestionsViewState {
        let domainNames = searchContext.knownDomainsStorage.domainNames(whereURLContains: query)
        do {
            let suggestions = try await autocomplete.aaFetchSuggestions(query)
            return .everythingLoaded(domainNames, suggestions)
        } catch {
            return .knownDomainsLoaded(domainNames)
        }
    }
}
