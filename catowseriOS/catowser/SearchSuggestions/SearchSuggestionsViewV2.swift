//
//  SearchSuggestionsViewV2.swift
//  catowser
//
//  Created by Andrei Ermoshin on 3/29/23.
//  Copyright © 2023 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import SwiftUI
import CottonData

struct SearchSuggestionsViewV2: View {
    /// Used in waitingForQuery
    private var searchQuery: String
    /// Used when user selects suggestion
    private weak var delegate: SearchSuggestionsListDelegate?
    /// Save currently selected suggestion to be able to observe it
    @State private var selected: SuggestionType?
    /// Used to update the view from loading to suggestions list
    @State private var suggestions: SearchSuggestionsViewState = .waitingForQuery
    /// A view model
    private let vm: SearchSuggestionsViewModel
    
    init(_ searchQuery: String,
         _ delegate: SearchSuggestionsListDelegate?,
         _ vm: SearchSuggestionsViewModel) {
        self.searchQuery = searchQuery
        self.delegate = delegate
        self.vm = vm
        /// Possibly already not needed check 
        if !searchQuery.isEmpty {
            suggestions = .waitingForQuery
        }
    }
    
    var body: some View {
        dynamicView
            .onChange(of: selected) { newValue in
                guard let newValue else {
                    return
                }
                Task {
                    await delegate?.searchSuggestionDidSelect(newValue)
                }
            }
            .onReceive(vm.statePublisher, perform: { state in
                suggestions = state
            })
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
                        // just asking for a new state, could wait for it as well
                        await vm.fetchSuggestions(searchQuery)
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

#if DEBUG
struct SearchSuggestionsViewV2_Previews: PreviewProvider {
    static var previews: some View {
        let delegate: SearchSuggestionsListDelegate? = nil
        let searchQuery: String = "e"
        
        let vm: SearchSuggestionsViewModel = ViewModelFactory.shared.searchSuggestionsViewModel(.duckduckgo)

        SearchSuggestionsViewV2(searchQuery, delegate, vm)
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
    }
}
#endif
