//
//  MenuButton.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/26/23.
//  Copyright © 2023 Cotton (former Catowser). All rights reserved.
//

import SwiftUI

/// Menu button
public struct MenuButton: View {
    @Binding private var showSearchSuggestions: Bool
    @Binding private var showingMenu: Bool

    /// Init
    public init(
        _ showSearchSuggestions: Binding<Bool>,
        _ showingMenu: Binding<Bool>
    ) {
        _showSearchSuggestions = showSearchSuggestions
        _showingMenu = showingMenu
    }

    /// View body
    public var body: some View {
        Button {
            showSearchSuggestions = false
            withAnimation(.easeInOut(duration: 1)) {
                showingMenu.toggle()
            }
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
        .foregroundColor(.black)
    }
}

struct MenuButton_Previews: PreviewProvider {
    static var previews: some View {
        let showSearchSuggestions: Binding<Bool> = .init {
            false
        } set: { _ in
            //
        }
        let showingMenu: Binding<Bool> = .init {
            false
        } set: { _ in
            //
        }
        MenuButton(showSearchSuggestions, showingMenu)
    }
}
