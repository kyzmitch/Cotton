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
    @Binding private var searchQuery: String
    private weak var delegate: SearchSuggestionsListDelegate?
    private let mode: SwiftUIMode
    private let searchProviderType: WebAutoCompletionSource
    private let vm: SearchSuggestionsViewModel
    
    init(_ searchQuery: Binding<String>,
         _ delegate: SearchSuggestionsListDelegate?,
         _ mode: SwiftUIMode,
         _ searchProviderType: WebAutoCompletionSource) {
        _searchQuery = searchQuery
        self.delegate = delegate
        self.mode = mode
        self.searchProviderType = searchProviderType
        vm = ViewModelFactory.shared.searchSuggestionsViewModel(searchProviderType)
    }
    
    var body: some View {
        switch mode {
        case .compatible:
            SearchSuggestionsLegacyView($searchQuery, delegate, searchProviderType)
        case .full:
            SearchSuggestionsViewV2($searchQuery, delegate, vm)
        }
    }
}

#if DEBUG
struct SearchSuggestionsView_Previews: PreviewProvider {
    static var previews: some View {
        let state: Binding<String> = .init {
            "cotton"
        } set: { _ in
            //
        }
        SearchSuggestionsView(state, nil, .compatible, .google)
    }
}
#endif
