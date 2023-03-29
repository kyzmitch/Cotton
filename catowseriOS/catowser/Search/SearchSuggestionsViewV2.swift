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
    @Binding private var searchQuery: String
    private weak var delegate: SearchSuggestionsListDelegate?
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
                    ForEach(knownDomains) { SuggestionRow(value: $0)}
                } header: {
                    Text(verbatim: suggestions.sectionTitle(section: 0) ?? "Known domains")
                }
            })
        case .everythingLoaded(let knownDomains, let querySuggestions):
            return AnyView(List {
                Section {
                    ForEach(knownDomains) { SuggestionRow(value: $0)}
                } header: {
                    Text(verbatim: suggestions.sectionTitle(section: 0) ?? "Known domains")
                }
                Section {
                    ForEach(querySuggestions) { SuggestionRow(value: $0)}
                } header: {
                    Text(verbatim: suggestions.sectionTitle(section: 1) ?? "Suggestions from search engine")
                }
            })
        }
    }
}

private struct SuggestionRow: View {
    var value: String
    
    var body: some View {
        Text(value)
    }
}

private extension String {
    static let globalSectionTtl = NSLocalizedString("ttl_global_menu", comment: "")
}
