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
    @State private var searchText: String
    @State private var showCancelButton: Bool
    private var model: SearchBarViewModel
    @Binding private var stateBinding: SearchBarState
    
    init(_ model: SearchBarViewModel,
         _ stateBinding: Binding<SearchBarState>) {
        self.searchText = ""
        self.showCancelButton = false
        self.model = model
        _stateBinding = stateBinding
    }
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField(.placeholderTextKey, text: $searchText, onEditingChanged: { _ in
                    self.showCancelButton = true
                }, onCommit: {
                    print("onCommit")
                }).foregroundColor(.primary)
                
                Button(action: {
                    self.searchText = ""
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .opacity(searchText == "" ? 0 : 1)
                })
            }
            .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
            .foregroundColor(.secondary)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10.0)
            
            if showCancelButton {
                Button("Cancel") {
                    // this must be placed before the other commands here
                    UIApplication.shared.endEditing(true)
                    self.searchText = ""
                    self.showCancelButton = false
                }
                .foregroundColor(Color(.systemBlue))
            }
        }
        .padding(.horizontal)
        .navigationBarHidden(showCancelButton) // .animation(.default)
    }
}

#if DEBUG
struct SearchBarViewV2_Previews: PreviewProvider {
    static var previews: some View {
        let model = SearchBarViewModel()
        let state: Binding<SearchBarState> = .init {
            .startSearch
        } set: { _ in
            //
        }
        // For some reason it jumps after selection
        SearchBarViewV2(model, state)
    }
}
#endif
