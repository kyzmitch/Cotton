//
//  SearchSuggestionsView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 1/4/23.
//  Copyright © 2023 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import SwiftUI
import CottonData

struct SearchSuggestionsView: View {
    private let searchQuery: String
    private weak var delegate: SearchSuggestionsListDelegate?
    private let mode: SwiftUIMode
    private let searchProviderType: WebAutoCompletionSource
    private let vm: SearchSuggestionsViewModel
    
    init(_ searchQuery: String,
         _ delegate: SearchSuggestionsListDelegate?,
         _ mode: SwiftUIMode,
         _ searchProviderType: WebAutoCompletionSource) {
        self.searchQuery = searchQuery
        self.delegate = delegate
        self.mode = mode
        self.searchProviderType = searchProviderType
        vm = ViewModelFactory.shared.searchSuggestionsViewModel(searchProviderType)
    }
    
    var body: some View {
        switch mode {
        case .compatible:
            SearchSuggestionsLegacyView(searchQuery, delegate, searchProviderType)
        case .full:
            SearchSuggestionsViewV2(searchQuery, delegate, vm)
        }
    }
}

#if DEBUG
struct SearchSuggestionsView_Previews: PreviewProvider {
    static var previews: some View {
        let state: String = "cotton"
        SearchSuggestionsView(state, nil, .compatible, .google)
    }
}
#endif
