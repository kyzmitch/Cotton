//
//  SearchBarV2View.swift
//  catowser
//
//  Created by Andrey Ermoshin on 10.12.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI

// https://stackoverflow.com/questions/56490963/how-to-display-a-search-bar-with-swiftui

/**
 There are possibly 3 options on how to create a search bar:
 - wrap UIKit's UISearchBar view into some struct which confirms to `UIViewRepresentable`
 - write own implementation as below
 - use iOS 15 `searchable` property on some view
 
 Need to not forget to use ThemeProvider.shared.setup(view)
 for search bar view to make it similar with UIKit version.
 */

struct SearchBarView: View {
    var body: some View {
        _SearchBarLegacyView()
    }
}

private struct _SearchBarLegacyView: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        let uiKitView = SearchBarLegacyView(frame: .zero)
        return uiKitView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

private struct _SearchBarView: View {
    @State private var searchText = ""
    @State private var showCancelButton: Bool = false
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                
                TextField("search", text: $searchText, onEditingChanged: { _ in
                    self.showCancelButton = true
                }, onCommit: {
                    print("onCommit")
                }).foregroundColor(.primary)
                
                Button(action: {
                    self.searchText = ""
                }, label: {
                    Image(systemName: "xmark.circle.fill").opacity(searchText == "" ? 0 : 1)
                })
            }
            .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
            .foregroundColor(.secondary)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10.0)
            
            if showCancelButton {
                Button("Cancel") {
                    UIApplication.shared.endEditing(true) // this must be placed before the other commands here
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

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView()
    }
}
