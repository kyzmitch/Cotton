//
//  SearchSuggestionsViewV2.swift
//  catowser
//
//  Created by Andrei Ermoshin on 3/29/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI

struct SearchSuggestionsViewV2: View {
    @Binding private var searchQuery: String
    private weak var delegate: SearchSuggestionsListDelegate?
    
    init(_ searchQuery: Binding<String>,
         _ delegate: SearchSuggestionsListDelegate?) {
        _searchQuery = searchQuery
        self.delegate = delegate
    }
    
    var body: some View {
        // TODO: add list
        Text(verbatim: "Suggestions list")
    }
}
