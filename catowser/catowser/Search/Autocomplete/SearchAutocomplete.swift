//
//  SearchAutocomplete.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/5/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import BrowserNetworking

/// Web search suggestions (search autocomplete) facade
final class SearchAutocomplete {
    private let ddGoContext: DDGoContext
    private let ddGoStrategy: DDGoAutocompleteStrategy
    
    init() {
        ddGoContext = .init(DDGoSuggestionsClient.shared,
                            HttpEnvironment.shared.duckduckgoClientRxSubscriber,
                            HttpEnvironment.shared.duckduckgoClientSubscriber)
        ddGoStrategy = .init(ddGoContext)
    }
}
