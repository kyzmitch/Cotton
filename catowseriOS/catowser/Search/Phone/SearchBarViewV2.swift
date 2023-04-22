//
//  SearchBarViewV2.swift
//  catowser
//
//  Created by Andrei Ermoshin on 1/3/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI

extension LocalizedStringKey {
    static let placeholderTextKey: LocalizedStringKey = "placeholder_searchbar"
}

struct SearchBarViewV2: View {
    @Binding private var query: String
    @Binding private var state: SearchBarState
    @FocusState private var isFocused: Bool
    
    init(_ queryBinding: Binding<String>,
         _ stateBinding: Binding<SearchBarState>) {
        _query = queryBinding
        _state = stateBinding
        isFocused = false
    }
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField(.placeholderTextKey, text: $query)
                .foregroundColor(.primary)
                .focused($isFocused)
                .textInputAutocapitalization(.never)
                .onSubmit {
                    state = .cancelTapped
                }
                .onChange(of: isFocused, perform: { value in
                    if value {
                        state = .startSearch
                    }
                })
            if state.showCancelButton {
                Button(.cancelButtonTtl) {
                    state = .cancelTapped
                }
                .foregroundColor(.gray)
                .foregroundColor(Color(.systemBlue))
            }
        }
        .customHStackStyle()
        .onChange(of: state) { newValue in
            switch newValue {
            case .blankSearch:
                isFocused = false
                query = ""
            case .startSearch:
                isFocused = true
            case .cancelTapped:
                isFocused = false
            case .viewMode(_, let searchBarContent, _):
                isFocused = false
                query = searchBarContent
            }
        }
    }
}

private struct CustomHStackStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
            .foregroundColor(.secondary)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10.0)
    }
}

extension View {
    func customHStackStyle() -> some View {
        modifier(CustomHStackStyle())
    }
}

private extension LocalizedStringKey {
    static let cancelButtonTtl: LocalizedStringKey = "ttl_common_cancel"
}

#if DEBUG
struct SearchBarViewV2_Previews: PreviewProvider {
    static var previews: some View {
        let state: Binding<SearchBarState> = .init {
            .startSearch
        } set: { _ in
            //
        }
        let query: Binding<String> = .init {
            ""
        } set: { _ in
            //
        }

        // For some reason it jumps after selection
        SearchBarViewV2(query, state)
    }
}
#endif
