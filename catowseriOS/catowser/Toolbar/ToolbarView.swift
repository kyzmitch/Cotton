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
    private(set) var model: WebBrowserToolbarModel
    @Binding private var webViewInterface: WebViewNavigatable?
    
    init(_ model: WebBrowserToolbarModel, _ webViewInterface: Binding<WebViewNavigatable?>) {
        self.model = model
        _webViewInterface = webViewInterface
    }
    
    var body: some View {
        ToolbarLegacyView($webViewInterface)
            .frame(height: CGFloat.toolbarViewHeight)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                DummyView()
            }
            .onReceive(model.$webViewInterface) { value in
                webViewInterface = value
            }
    }
}

private struct DummyView: View {
    var body: some View {
        EmptyView()
            .frame(height: 0)
            .background(Color.phoneToolbarColor)
    }
}

#if DEBUG
struct ToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        let model = WebBrowserToolbarModel()
        let state: Binding<WebViewNavigatable?> = .init {
            nil
        } set: { _ in
            //
        }
        ToolbarView(model, state)
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
    }
}
#endif
