//
//  ToolbarView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/11/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit
import SwiftUI

struct ToolbarView: View {
    @ObservedObject var model: WebBrowserToolbarModel
    @Binding var webViewInterface: WebViewNavigatable?
    
    var body: some View {
        ToolbarLegacyView(webViewInterface: webViewInterface)
    }
}

private struct ToolbarLegacyView: UIViewRepresentable {
    let webViewInterface: WebViewNavigatable?
    
    func makeUIView(context: Context) -> some UIView {
        let interface = context.environment.browserContentCoordinators
        let uiKitView = WebBrowserToolbarView(frame: .zero)
        uiKitView.globalSettingsDelegate = interface?.globalMenuDelegate
        uiKitView.webViewInterface = webViewInterface
        ThemeProvider.shared.setup(uiKitView)
        return uiKitView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {

    }
}
