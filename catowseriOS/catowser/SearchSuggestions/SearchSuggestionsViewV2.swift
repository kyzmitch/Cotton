//
//  SearchSuggestionsViewV2.swift
//  catowser
//
//  Created by Andrei Ermoshin on 3/29/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI
import CoreCatowser

struct SearchSuggestionsViewV2: View {
    /// Used in waitingForQuery
    @Binding private var searchQuery: String
    /// Used when user selects suggestion
    private weak var delegate: SearchSuggestionsListDelegate?
    /// Save currently selected suggestion to be able to observe it
    @State private var selected: SuggestionType?
    /// Used to update the view from loading to suggestions list
    @State private var suggestions: SearchSuggestionsViewState = .waitingForQuery
    /// A view model
    private let vm: SearchSuggestionsViewModel
    
    init(_ searchQuery: Binding<String>,
         _ delegate: SearchSuggestionsListDelegate?) {
        _searchQuery = searchQuery
        self.delegate = delegate
        vm = ViewModelFactory.shared.searchSuggestionsViewModel()
    }
    
    var body: some View {
        dynamicView
            .onChange(of: selected) { newValue in
                guard let newValue else {
                    return
                }
                delegate?.searchSuggestionDidSelect(newValue)
            }
            .onChange(of: searchQuery) { _ in
                if !searchQuery.isEmpty {
                    suggestions = .waitingForQuery
                }
            }
    }
    
    @ViewBuilder
    private var dynamicView: some View {
        switch suggestions {
        case .waitingForQuery:
            VStack {
                Spacer()
                ProgressView()
                    .progressViewStyle(.circular)
                    .task {
                        suggestions = await vm.aaFetchSuggestions(searchQuery)
                    }
                Spacer()
            }
        case .knownDomainsLoaded(let knownDomains):
            List {
                Section {
                    ForEach(knownDomains) { SuggestionRowView($0, .domain, $selected)}
                } header: {
                    Text(verbatim: suggestions.sectionTitle(section: 0) ?? "Known domains")
                }
            }
        case .everythingLoaded(let knownDomains, let querySuggestions):
            List {
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
            }
        } // switch
    } // construct view
}
