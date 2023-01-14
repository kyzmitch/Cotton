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
import CoreBrowser

public typealias KnownDomains = [String]
public typealias QuerySuggestions = [String]

/// View state, without error, because we want to show at least known domains even if there was a network failure
/// Need to return to `waitingForQuery` state after view changes the text
public enum SearchSuggestionsViewState: Equatable {
    case waitingForQuery
    case knownDomainsLoaded(KnownDomains)
    case everythingLoaded(KnownDomains, QuerySuggestions)
    
    public func rowsCount(_ section: Int) -> Int {
        switch self {
        case .waitingForQuery:
            return 0
        case .knownDomainsLoaded(let knownDomains):
            return knownDomains.count
        case .everythingLoaded(let knownDomains, let querySuggestions):
            if section == 0 {
                return knownDomains.count
            } else if section == 1 {
                return querySuggestions.count
            } else {
                let errMsg = "Not expected section number for suggestions state"
                #if TESTING
                #else
                // can't assert here because of unit tests
                print(errMsg)
                #endif
                return -1
            }
        }
    }
    
    public var sectionsNumber: Int {
        switch self {
        case .waitingForQuery:
            return 0
        case .knownDomainsLoaded:
            return 1
        case .everythingLoaded:
            return 2
        }
    }
    
    public func value(from row: Int, section: Int) -> String? {
        switch self {
        case .knownDomainsLoaded(let knownDomains):
            return knownDomains[safe: row]
        case .everythingLoaded(let knownDomains, let querySuggestions):
            if section == 0 {
                return knownDomains[row]
            } else if section == 1 {
                return querySuggestions[row]
            } else {
                assertionFailure("Not expected section number for suggestions state")
                return nil
            }
        default:
            return nil
        }
    }
}

public protocol SearchSuggestionsViewModel: AnyObject {
    /// Initiate fetching only after subscribing to the async interfaces below
    func fetchSuggestions(_ query: String)
    
    /// Rx state property signal won't emit initial/current value (comparing to Combine)
    var rxState: MutableProperty<SearchSuggestionsViewState> { get }
    /// Combine state, emits current value for every new subscriber
    var combineState: CurrentValueSubject<SearchSuggestionsViewState, Never> { get }
    /// Concurrency state, also can be used as a synchronous state. A wrapped value for Published
    var state: SearchSuggestionsViewState { get }
    /// This is a replacement for Concurrency's `Task.Handler`, property wrapper can't be defined in protocol
    var statePublisher: Published<SearchSuggestionsViewState>.Publisher { get }
}
