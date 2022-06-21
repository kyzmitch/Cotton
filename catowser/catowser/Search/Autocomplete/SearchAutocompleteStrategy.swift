//
//  SearchAutocompleteStrategy.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/21/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import HttpKit
import ReactiveSwift
import Combine

protocol SearchAutocompleteStrategy: AnyObject {
    associatedtype Context: SearchAutocompleteContext
    
    init(_ context: Context)
    func suggestionsProducer(for text: String) -> SignalProducer<SearchSuggestionsResponse, HttpKit.HttpError>
    func suggestionsPublisher(for text: String) -> AnyPublisher<SearchSuggestionsResponse, HttpKit.HttpError>
}
