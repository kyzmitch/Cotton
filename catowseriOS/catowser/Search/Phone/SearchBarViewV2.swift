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

/**
 A search bar fully implemented in SwiftUI.
 
 Still need to implement the following:
 - after moving focus to TextField (tap on it) if query is not empty, then need to select all text
 which would allow to easely clear/remove currently entered query string. The same behaviour has Safari for iOS.
 */
struct SearchBarViewV2: View {
    @Binding private var query: String
    @Binding private var action: SearchBarAction
    @State private var state: SearchBarState
    @FocusState private var isFocused: Bool
    
    init(_ query: Binding<String>,
         _ action: Binding<SearchBarAction>) {
        _query = query
        _action = action
        state = .blankViewMode
        isFocused = false
    }
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField(.placeholderTextKey, text: $query)
                .foregroundColor(.primary)
                .textInputAutocapitalization(.never)
                .textSelection(.enabled)
                .focused($isFocused)
                .onSubmit {
                    action = .cancelTapped
                }
                .onChange(of: isFocused, perform: { value in
                    if value {
                        action = .startSearch
                    }
                })
            if action.showCancelButton {
                if !query.isEmpty {
                    Button {
                        query = ""
                    } label: {
                        Image(systemName: "x.circle.fill")
                    }
                }
                Button(.cancelButtonTtl) {
                    action = .cancelTapped
                }
                .foregroundColor(.gray)
            }
        }
        .customHStackStyle()
        .onChange(of: action) { newValue in
            switch newValue {
            case .startSearch:
                state = .inSearchMode(state.title, state.content)
            case .cancelTapped:
                if state.content.isEmpty {
                    state = .blankViewMode
                } else {
                    state = .viewMode(state.title, state.content, true)
                }
            case .updateView(let title, let content):
                state = .viewMode(title, content, false)
            }
        }
        .onChange(of: state) { newValue in
            switch newValue {
            case .blankViewMode:
                isFocused = false
                query = ""
            case .inSearchMode:
                isFocused = true
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

        // For some reason it jumps after selection
        SearchBarViewV2(query, state)
    }
}
#endif
