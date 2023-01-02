//
//  CottonToolbarV2View.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/11/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit
import SwiftUI

struct ToolbarView: View {
    var body: some View {
        _ToolbarLegacyView()
    }
}

private struct _ToolbarLegacyView: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        let interface = context.environment.browserContentCoordinators
        let uiKitView = WebBrowserToolbarView(frame: .zero)
        uiKitView.globalSettingsDelegate = interface?.globalMenuDelegate
        ThemeProvider.shared.setup(uiKitView)
        return uiKitView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

// https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-a-toolbar-and-add-buttons-to-it

private struct _ToolbarView: View {
    var body: some View {
        NavigationView {
            
        }.toolbar {
            ToolbarItem(placement: .principal) {
                Button(role: nil) {
                    
                } label: {
                    Image("nav-back")
                }

            }
            ToolbarItem(placement: .principal) {
                Button(role: nil) {
                    
                } label: {
                    Image("nav-forward")
                }
            }
            ToolbarItem(placement: .principal) {
                Button(role: nil) {
                    
                } label: {
                    Image("nav-refresh")
                }
            }
            ToolbarItem(placement: .principal) {
                Button(role: nil) {
                    
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            ToolbarItem(placement: .principal) {
                Button(role: nil) {
                    
                } label: {
                    Image("nav-downloads")
                }
            }
        }
    }
}
