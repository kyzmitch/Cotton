//
//  ToolbarViewV2.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/21/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI

struct ToolbarViewV2: ToolbarContent {
    private let model: WebBrowserToolbarModel
    @Binding private var showingMenu: Bool
    
    init(_ model: WebBrowserToolbarModel,
         _ showingMenu: Binding<Bool>) {
        self.model = model
        _showingMenu = showingMenu
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
                withAnimation(.easeInOut(duration: 1)) {
                    showingMenu.toggle()
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
        }
    }
}
