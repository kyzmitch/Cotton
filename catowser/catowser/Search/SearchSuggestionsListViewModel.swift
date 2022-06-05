//
//  SearchSuggestionsListViewModel.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/5/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import CoreBrowser
import ReactiveSwift
import FeaturesFlagsKit
import Combine
import BrowserNetworking
import HttpKit

protocol SearchSuggestionsListViewModel: AnyObject {
    
}

final class SearchSuggestionsListViewModelImpl {
    var suggestions: [String] = [] {
        didSet {
            // tableView.reloadData()
        }
    }

    private var knownDomains: [String] = [] {
        didSet {
            // tableView.reloadData()
        }
    }
    
    /// Not private to allow access from extension
    let googleClient: GoogleSuggestionsClient
    ///
    let ddGoClient: DDGoSuggestionsClient
    
    private let waitingQueueName: String = .queueNameWith(suffix: "searchThrottle")
    
    private lazy var waitingScheduler = QueueScheduler(qos: .userInitiated,
                                                       name: waitingQueueName,
                                                       targeting: waitingQueue)
    
    private lazy var waitingQueue = DispatchQueue(label: waitingQueueName)
    
#if swift(>=5.5)
    /// Not private to make it available for extension with async await
    // @available(swift 5.5)
    @available(iOS 15.0, *)
    lazy var searchSuggestionTaskHandler: Task.Handle<[String], Error>? = nil
#endif
    
    init() {
        googleClient = GoogleSuggestionsClient.shared
        ddGoClient = DDGoSuggestionsClient.shared
    }
    
    deinit {
        if #available(iOS 13.0, *) {
            searchSuggestionsCancellable?.cancel()
        } else {
            searchSuggestionsDisposable?.dispose()
        }
    }
    
    func prepareSearch(for searchText: String) {
        suggestions.removeAll()
        knownDomains = InMemoryDomainSearchProvider.shared.domainNames(whereURLContains: searchText)
        switch FeatureManager.appAsyncApiTypeValue() {
        case .reactive:
            rxPrepareSearch(for: searchText)
        case .combine:
            if #available(iOS 13.0, *) {
                combinePrepareSearch(for: searchText)
            } else {
                assertionFailure("Attempt to use Combine API when iOS < 13.x")
            }
        case .asyncAwait:
            if #available(iOS 15.0, *) {
    #if swift(>=5.5)
                async { await aaPrepareSearch(for: searchText) }
    #else
                assertionFailure("Swift version isn't 5.5")
    #endif
            }
        }
    }
    
    @available(iOS 13.0, *)
    private func combinePrepareSearch(for searchText: String) {
        searchSuggestionsCancellable?.cancel()
        let source = Just<String>(searchText)
        searchSuggestionsCancellable = source
            .delay(for: 0.5, scheduler: waitingQueue)
            .mapError({ (_) -> HttpKit.HttpError in
                // workaround to be able to compile case when `Just` has no error type for Failure
                // but it is required to be able to use `flatMap` in next call
                // another option is to use custom publisher which supports non Never Failure type
                return .zombieSelf
            })
            .flatMap({ [weak self] (text) -> CGSearchPublisher in
                guard let self = self else {
                    typealias SuggestionsResult = Result<GSearchSuggestionsResponse, HttpKit.HttpError>
                    let errorResult: SuggestionsResult = .failure(.zombieSelf)
                    return errorResult.publisher.eraseToAnyPublisher()
                }
                let subscriber = HttpEnvironment.shared.googleClientSubscriber
                let ddgoSubscriber = HttpEnvironment.shared.duckduckgoClientSubscriber
                switch FeatureManager.webSearchAutoCompleteValue() {
                case .google:
                    return self.googleClient.cGoogleSearchSuggestions(for: text, subscriber)
                case .duckduckgo:
                    return self.ddGoClient.cDuckDuckgoSuggestions(for: text, subscriber: ddgoSubscriber)
                        .map { $0.googleResponse }
                        .eraseToAnyPublisher()
                }
            })
            .receive(on: DispatchQueue.main)
            .map { $0.textResults }
            .catch({ (failure) -> Just<[String]> in
                print("Fail to fetch search suggestions \(failure.localizedDescription)")
                return .init([])
            })
            .assign(to: \.suggestions, on: self)
    }
    
    private func rxPrepareSearch(for searchText: String) {
        searchSuggestionsDisposable?.dispose()
        let source = SignalProducer<String, Never>.init(value: searchText)
        searchSuggestionsDisposable = source
            .delay(0.5, on: waitingScheduler)
            .flatMap(.latest, { [weak self] (text) -> GSearchProducer in
                guard let self = self else {
                    return .init(error: .zombieSelf)
                }
                let subscriber = HttpEnvironment.shared.googleClientRxSubscriber
                let ddgoSubscriber = HttpEnvironment.shared.duckduckgoClientRxSubscriber
                switch FeatureManager.webSearchAutoCompleteValue() {
                case .google:
                    return self.googleClient.googleSearchSuggestions(for: text, subscriber)
                case .duckduckgo:
                    return self.ddGoClient.duckDuckGoSuggestions(for: text, subscriber: ddgoSubscriber)
                        .map { $0.googleResponse }
                }
            })
            .observe(on: QueueScheduler.main)
            .startWithResult { [weak self] (result) in
                switch result {
                case .success(let response):
                    self?.suggestions = response.textResults
                case .failure(let error):
                    print("Fail to fetch search suggestions \(error.localizedDescription)")
                }
        }
    }
    
    @available(iOS 13.0, *)
    private lazy var searchSuggestionsCancellable: AnyCancellable? = nil
    
    private var searchSuggestionsDisposable: Disposable?
}

extension DDGoSuggestionsResponse {
    var googleResponse: GSearchSuggestionsResponse {
        .init(queryText, textResults)
    }
}
