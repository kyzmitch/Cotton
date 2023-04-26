//
//  ToolbarViewV2.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/21/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI
import CoreBrowser

struct ToolbarViewV2: ToolbarContent {
    private let vm: BrowserToolbarViewModel
    @Binding private var tabsCount: Int
    @Binding private var showingMenu: Bool
    @Binding private var showingTabs: Bool
    @Binding private var showSearchSuggestions: Bool
    
    @State private var isGoBackDisabled: Bool
    @State private var isGoForwardDisabled: Bool
    @State private var isRefreshDisabled: Bool
    
    init(_ vm: BrowserToolbarViewModel,
         _ tabsCount: Binding<Int>,
         _ showingMenu: Binding<Bool>,
         _ showingTabs: Binding<Bool>,
         _ showSearchSuggestions: Binding<Bool>) {
        self.vm = vm
        _tabsCount = tabsCount
        _showingMenu = showingMenu
        _showingTabs = showingTabs
        _showSearchSuggestions = showSearchSuggestions
        isGoBackDisabled = false
        isGoForwardDisabled = false
        isRefreshDisabled = false
    }
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Button {
                vm.goBack()
            } label: {
                Image("nav-back")
            }
            .disabled(isGoBackDisabled)
            .opacity(isGoBackDisabled ? ThemeProvider.disabledOpacity : 1)
            .onReceive(vm.$goBackDisabled) { isGoBackDisabled = $0 }
        }
        ToolbarItem(placement: .bottomBar) {
            Spacer()
        }
        ToolbarItem(placement: .bottomBar) {
            Button {
                vm.goForward()
            } label: {
                Image("nav-forward")
            }
            .disabled(isGoForwardDisabled)
            .opacity(isGoForwardDisabled ? ThemeProvider.disabledOpacity : 1)
            .onReceive(vm.$goForwardDisabled) { isGoForwardDisabled = $0 }
        }
        ToolbarItem(placement: .bottomBar) {
            Spacer()
        }
        ToolbarItem(placement: .bottomBar) {
            Button {
                vm.reload()
            } label: {
                Image("nav-refresh")
            }
            .disabled(isRefreshDisabled)
            .opacity(isRefreshDisabled ? ThemeProvider.disabledOpacity : 1)
            .onReceive(vm.$reloadDisabled) { isRefreshDisabled = $0 }
        }
        ToolbarItem(placement: .bottomBar) {
            Spacer()
        }
        ToolbarItem(placement: .bottomBar) {
            Button {
                showSearchSuggestions = false
                withAnimation(.easeInOut(duration: 1)) {
                    showingTabs.toggle()
                }
            } label: {
                Text(verbatim: "\(tabsCount)")
            }
            .foregroundColor(.black)
        }
        ToolbarItem(placement: .bottomBar) {
            Spacer()
        }
        ToolbarItem(placement: .bottomBar) {
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
}
