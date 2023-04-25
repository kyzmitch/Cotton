//
//  SearchBarViewV2.swift
//  catowser
//
//  Created by Andrei Ermoshin on 1/3/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI

/**
 A search bar fully implemented in SwiftUI.
 
 Still need to implement the following:
 - after moving focus to TextField (tap on it) if query is not empty, then need to select all text
 which would allow to easely clear/remove currently entered query string. The same behaviour has Safari for iOS.
 */
struct SearchBarViewV2: View {
    @Binding private var query: String
    @Binding private var action: SearchBarAction
    @State private var showClearButton: Bool
    @State private var state: SearchBarState
    @State private var siteName: String
    @State private var showOverlay: Bool
    @State private var showKeyboard: Bool
    
    private let cancelBtnVM: ClearCancelButtonViewModel
    private let textFieldVM: SearchFieldViewModel
    private let overlayVM: TappableTextOverlayViewModel
    
    private var overlayHidden: CGFloat {
        UIScreen.main.bounds.width
    }
    private let overlayVisible: CGFloat = 0
    
    init(_ query: Binding<String>,
         _ action: Binding<SearchBarAction>) {
        _query = query
        _action = action
        cancelBtnVM = .init()
        textFieldVM = .init()
        overlayVM = .init()
        showClearButton = false
        state = .blankViewMode
        siteName = ""
        showOverlay = true
        showKeyboard = false
    }
    
    var body: some View {
        ZStack {
            HStack {
                SearchFieldView($query, $showKeyboard, textFieldVM)
                if action.showCancelButton {
                    ClearCancelPairButton($showClearButton, cancelBtnVM)
                }
            }.customHStackStyle()
                .opacity(showOverlay ? 0 : 1)
                .animation(.easeInOut(duration: SearchBarConstants.animationDuration), value: showOverlay)
            TappableTextOverlayView($siteName, overlayVM)
                .offset(x: showOverlay ? overlayVisible : overlayHidden, y: 0)
                .animation(.easeInOut(duration: SearchBarConstants.animationDuration), value: showOverlay)
        }
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
                showKeyboard = false
                query = ""
                siteName = ""
                showOverlay = true
            case .inSearchMode:
                showOverlay = false
                showKeyboard = true
            case .viewMode(let title, let content, _):
                showKeyboard = false
                query = content
                siteName = title
                showOverlay = true
            }
        }
        .onChange(of: query) { showClearButton = !$0.isEmpty }
        .onReceive(cancelBtnVM.$clearTapped.dropFirst()) { query = "" }
        .onReceive(cancelBtnVM.$cancelTapped.dropFirst()) { action = .cancelTapped }
        .onReceive(textFieldVM.$submitTapped.dropFirst()) { action = .cancelTapped }
        .onReceive(textFieldVM.$isFocused) { newValue in
            if newValue {
                action = .startSearch
            }
        }
        .onReceive(overlayVM.$tapped.dropFirst()) { action = .startSearch }
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
