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
    private let model: WebBrowserToolbarModel
    @Binding private var tabsCount: Int
    @Binding private var showingMenu: Bool
    @Binding private var showingTabs: Bool
    @Binding private var showSearchSuggestions: Bool
    
    init(_ model: WebBrowserToolbarModel,
         _ tabsCount: Binding<Int>,
         _ showingMenu: Binding<Bool>,
         _ showingTabs: Binding<Bool>,
         _ showSearchSuggestions: Binding<Bool>) {
        self.model = model
        _tabsCount = tabsCount
        _showingMenu = showingMenu
        _showingTabs = showingTabs
        _showSearchSuggestions = showSearchSuggestions
    }
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Button {
                model.goBack()
            } label: {
                Image("nav-back")
            }
            .disabled(model.goBackDisabled)
        }
        ToolbarItem(placement: .bottomBar) {
            Spacer()
        }
        ToolbarItem(placement: .bottomBar) {
            Button {
                model.goForward()
            } label: {
                Image("nav-forward")
            }
            .disabled(model.goForwardDisabled)
        }
        ToolbarItem(placement: .bottomBar) {
            Spacer()
        }
        ToolbarItem(placement: .bottomBar) {
            Button {
                model.reload()
            } label: {
                Image("nav-refresh")
            }
            .disabled(model.reloadDisabled)
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
        }
    }
}
