//
//  SearchSuggestionsView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 1/4/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI
import CottonData

struct SearchSuggestionsView: View {
    private let searchQuery: String
    private weak var delegate: SearchSuggestionsListDelegate?
    private let mode: SwiftUIMode
    private let viewModel: SearchSuggestionsViewModel
    
    init(_ searchQuery: String,
         _ delegate: SearchSuggestionsListDelegate?,
         _ mode: SwiftUIMode,
         _ viewModel: SearchSuggestionsViewModel) {
        self.searchQuery = searchQuery
        self.delegate = delegate
        self.mode = mode
        self.viewModel = viewModel
    }
    
    var body: some View {
        switch mode {
        case .compatible:
            SearchSuggestionsLegacyView(searchQuery, delegate, viewModel)
        case .full:
            SearchSuggestionsViewV2(searchQuery, delegate, viewModel)
        }
    }
}
