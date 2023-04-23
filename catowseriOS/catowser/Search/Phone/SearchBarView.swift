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
    /// Optional search bar delegate only needed for UIKit wrapper
    private weak var searchBarDelegate: UISearchBarDelegate?
    /// A search query stored in super view and used only by fully SwiftUI view
    @Binding private var searchQuery: String
    @Binding private var action: SearchBarAction
    private let mode: SwiftUIMode
    
    init(_ searchBarDelegate: UISearchBarDelegate?,
         _ searchQuery: Binding<String>,
         _ action: Binding<SearchBarAction>,
         _ mode: SwiftUIMode) {
        self.searchBarDelegate = searchBarDelegate
        _searchQuery = searchQuery
        _action = action
        self.mode = mode
    }
    
    var body: some View {
        switch mode {
        case .compatible:
            PhoneSearchBarLegacyView(searchBarDelegate, $action)
                .frame(height: CGFloat.searchViewHeight)
        case .full:
            SearchBarViewV2($searchQuery, $action)
        }
    }
}

#if DEBUG
struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        let searchBarDelegate: UISearchBarDelegate? = nil
        let state: Binding<SearchBarAction> = .init {
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
        SearchBarView(searchBarDelegate, query, state, .compatible)
    }
}
#endif
