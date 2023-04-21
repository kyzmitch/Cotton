//
//  SearchBarV2View.swift
//  catowser
//
//  Created by Andrey Ermoshin on 10.12.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI

/// A search bar view
struct SearchBarView: View {
    private var model: SearchBarViewModel
    @Binding private var searchQuery: String
    @Binding private var state: SearchBarState
    private let mode: SwiftUIMode
    
    init(_ model: SearchBarViewModel,
         _ searchQuery: Binding<String>,
         _ state: Binding<SearchBarState>,
         _ mode: SwiftUIMode) {
        self.model = model
        _searchQuery = searchQuery
        _state = state
        self.mode = mode
    }
    
    var body: some View {
        switch mode {
        case .compatible:
            PhoneSearchBarLegacyView(model, $state)
                .frame(height: CGFloat.searchViewHeight)
        case .full:
            SearchBarViewV2($searchQuery, $state)
        }
    }
}

#if DEBUG
struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        let model = SearchBarViewModel()
        let state: Binding<SearchBarState> = .init {
            // .viewMode("cotton", "cotton", true)
            .startSearch
        } set: { _ in
            //
        }
        let query: Binding<String> = .init {
            ""
        } set: { _ in
            //
        }
        // View is jumping when you tap on it
        SearchBarView(model, query, state, .compatible)
    }
}
#endif
