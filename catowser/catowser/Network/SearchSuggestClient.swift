//
//  SearchSuggestClient.swift
//  catowser
//
//  Created by Andrei Ermoshin on 14/02/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import ReactiveSwift


final class SearchSuggestClient {
    private let searchEngine: SearchEngine

    init(_ searchEngine: SearchEngine) {
        self.searchEngine = searchEngine
    }

    func constructSuggestions(basedOn query: String) -> SignalProducer<[String], SSError> {
        guard let url = searchEngine.suggestURLForQuery(query) else {
            return
        }


    }
}

extension SearchSuggestClient {
    enum SSError: Error{
        case wrongUrl
    }
}
