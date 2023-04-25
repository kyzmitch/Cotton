//
//  SearchTextField.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/25/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI

final class SearchTextFieldViewModel {
    @Published var isFocused: Bool
    @Published var submitTapped: Void
    
    init() {
        self.isFocused = false
        submitTapped = ()
    }
}

struct SearchTextField: View {
    @Binding private var textContent: String
    @Binding private var showKeyboard: Bool
    @FocusState private var isFocused: Bool
    
    private let vm: SearchTextFieldViewModel
    
    init(_ textContent: Binding<String>,
         _ showKeyboard: Binding<Bool>,
         _ vm: SearchTextFieldViewModel) {
        self.vm = vm
        _textContent = textContent
        _showKeyboard = showKeyboard
        isFocused = false
    }
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField(.placeholderTextKey, text: $textContent)
                .textInputAutocapitalization(.never)
                .textSelection(.enabled)
                .focused($isFocused)
                .onSubmit {
                    vm.submitTapped = ()
                }
        }
        .onChange(of: isFocused) { vm.isFocused = $0 }
        .onChange(of: showKeyboard) { isFocused = $0 }
    }
}

extension LocalizedStringKey {
    static let placeholderTextKey: LocalizedStringKey = "placeholder_searchbar"
}
