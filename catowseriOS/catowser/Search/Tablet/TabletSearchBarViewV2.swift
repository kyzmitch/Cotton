//
//  TabletSearchBarViewV2.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/26/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI

struct TabletSearchBarViewV2: View {
    @Binding private var showSearchSuggestions: Bool
    @Binding private var showingMenu: Bool
    @Binding private var query: String
    @Binding private var action: SearchBarAction
    
    /// Toolbar vm is better to be stored in Environment, because tablet view wrapper doesn't need it
    @EnvironmentObject var toolbarVM: BrowserToolbarViewModel
    
    private let maxWidth: CGFloat = UIScreen.main.bounds.width
    
    init(_ showingMenu: Binding<Bool>,
         _ showSearchSuggestions: Binding<Bool>,
         _ query: Binding<String>,
         _ action: Binding<SearchBarAction>) {
        _showingMenu = showingMenu
        _showSearchSuggestions = showSearchSuggestions
        _query = query
        _action = action
    }
    
    var body: some View {
        HStack {
            MenuButton($showSearchSuggestions, $showingMenu)
            Spacer()
            DisableableButton("nav-back", $toolbarVM.goBackDisabled, toolbarVM.goBack)
            Spacer()
            DisableableButton("nav-forward", $toolbarVM.goForwardDisabled, toolbarVM.goForward)
            Spacer()
            DisableableButton("nav-refresh", $toolbarVM.reloadDisabled, toolbarVM.reload)
            Spacer()
            SearchBarViewV2($query, $action)
        }
        .frame(maxWidth: maxWidth)
    }
}
