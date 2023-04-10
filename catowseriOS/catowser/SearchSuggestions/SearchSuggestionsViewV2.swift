//
//  SearchSuggestionsViewV2.swift
//  catowser
//
//  Created by Andrei Ermoshin on 3/29/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI
import CoreCatowser

/**
 List selection for different iOS versions (different SwiftUIs):
 https://sarunw.com/posts/swiftui-list-selection/
 */

struct SearchSuggestionsViewV2: View {
    /// Used in waitingForQuery
    @Binding private var searchQuery: String
    /// Used when user selects suggestion
    private weak var delegate: SearchSuggestionsListDelegate?
    /// Save currently selected suggestion to be able to observe it
    @State private var selected: SuggestionType?
    /// Used to update the view from loading to suggestions list
    @State private var suggestions: SearchSuggestionsViewState = .waitingForQuery
    private let vm: SearchSuggestionsViewModel
    
    init(_ searchQuery: Binding<String>,
         _ delegate: SearchSuggestionsListDelegate?) {
        _searchQuery = searchQuery
        self.delegate = delegate
        vm = ViewModelFactory.shared.searchSuggestionsViewModel()
    }
    
    var body: some View {
        constructView()
            .onChange(of: selected, perform: { newValue in
                guard let newValue else {
                    return
                }
                delegate?.didSelect(newValue)
            })
    }
    
    private func constructView() -> some View {
        switch suggestions {
        case .waitingForQuery:
            return AnyView(ProgressView()
                .task {
                    suggestions = await vm.aaFetchSuggestions(searchQuery)
                })
        case .knownDomainsLoaded(let knownDomains):
            return AnyView(List {
                Section {
                    ForEach(knownDomains) { SuggestionRowView($0, .domain, $selected)}
                } header: {
                    Text(verbatim: suggestions.sectionTitle(section: 0) ?? "Known domains")
                }
            })
        case .everythingLoaded(let knownDomains, let querySuggestions):
            return AnyView(List {
                Section {
                    ForEach(knownDomains) { SuggestionRowView($0, .domain, $selected)}
                } header: {
                    Text(verbatim: suggestions.sectionTitle(section: 0) ?? "Known domains")
                }
                Section {
                    ForEach(querySuggestions) { SuggestionRowView($0, .suggestion, $selected)}
                } header: {
                    Text(verbatim: suggestions.sectionTitle(section: 1) ?? "Suggestions from search engine")
                }
            })
        }
    }
}

private extension String {
    static let globalSectionTtl = NSLocalizedString("ttl_global_menu", comment: "")
}
