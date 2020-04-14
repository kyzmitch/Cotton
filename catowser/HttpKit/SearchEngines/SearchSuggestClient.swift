//
//  SearchSuggestClient.swift
//  catowser
//
//  Created by Andrei Ermoshin on 14/02/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import ReactiveSwift

public final class SearchSuggestClient {
    private let searchEngine: HttpKit.SearchEngine

    public init(_ searchEngine: HttpKit.SearchEngine) {
        self.searchEngine = searchEngine
    }

    /// Constructs search URL. Convinient wrapper around search engine class function.
    public func searchURL(basedOn query: String) -> URL? {
        return searchEngine.searchURLForQuery(query)
    }
}
