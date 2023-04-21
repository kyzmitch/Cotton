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
    }
    
    var body: some View {
        containedView()
            .onChange(of: state) { newValue in
                switch newValue {
                case .blankSearch:
                    query = ""
                case .startSearch:
                    break
                case .cancelTapped:
                    query = ""
                case .viewMode(_, let searchBarContent, _):
                    query = searchBarContent
            }
        }
    }
    
    private func containedView() -> AnyView {
        switch state {
        case .blankSearch, .cancelTapped, .viewMode:
            return searchViewInViewMode()
        case .startSearch:
            return searchViewInEditMode()
        }
    }
    
    private func searchViewInViewMode() -> AnyView {
        AnyView(HStack {
            Image(systemName: "magnifyingglass")
            TextField(.placeholderTextKey, text: $query)
                .foregroundColor(.primary)
                .focused($isFocused)
                .textInputAutocapitalization(.never)
                .onSubmit {
                    self.state = .startSearch
                }
                .onChange(of: isFocused, perform: { value in
                    if value {
                        state = .startSearch
                    }
                })
        }.customHStackStyle())
    }
    
    private func searchViewInEditMode() -> AnyView {
        AnyView(HStack {
            Image(systemName: "magnifyingglass")
            TextField(.placeholderTextKey, text: $query)
                .foregroundColor(.primary)
                .focused($isFocused)
                .textInputAutocapitalization(.never)
                .onSubmit {
                    self.state = .startSearch
                }
                .onChange(of: isFocused, perform: { value in
                    if value {
                        state = .startSearch
                    }
                })
            Button("Cancel") {
                self.state = .cancelTapped
            }
            .foregroundColor(.gray)
            .foregroundColor(Color(.systemBlue))
        }.customHStackStyle())
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
