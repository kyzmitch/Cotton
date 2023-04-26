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
    
    @State private var isGoBackEnabled: Bool
    @State private var isGoForwardEnabled: Bool
    @State private var isRefreshEnabled: Bool
    
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
        isGoBackEnabled = false
        isGoForwardEnabled = false
        isRefreshEnabled = false
    }
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Button {
                vm.goBack()
            } label: {
                Image("nav-back")
            }
            .disabled(isGoBackEnabled)
            .onReceive(vm.$goBackDisabled) { value in
                isGoBackEnabled = !value
            }
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
            .disabled(isGoForwardEnabled)
            .onReceive(vm.$goForwardDisabled) { value in
                isGoForwardEnabled = !value
            }
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
            .disabled(isRefreshEnabled)
            .onReceive(vm.$reloadDisabled) { value in
                isRefreshEnabled = !value
            }
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
