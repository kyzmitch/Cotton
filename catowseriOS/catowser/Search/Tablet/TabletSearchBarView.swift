//
//  TabletSearchBarView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 1/13/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI

/// A search bar view
struct TabletSearchBarView: View {
    private var model: SearchBarViewModel
    @Binding private var state: SearchBarState
    private(set) var toolbarModel: WebBrowserToolbarModel
    @Binding private var webViewInterface: WebViewNavigatable?
    
    init(_ model: SearchBarViewModel,
         _ state: Binding<SearchBarState>,
         _ toolbarModel: WebBrowserToolbarModel,
         _ webViewInterface: Binding<WebViewNavigatable?>) {
        self.model = model
        _state = state
        self.toolbarModel = toolbarModel
        _webViewInterface = webViewInterface
    }
    
    var body: some View {
        TabletSearchBarLegacyView(model, $state, $webViewInterface)
            .frame(height: CGFloat.searchViewHeight)
            .onReceive(toolbarModel.$webViewInterface) { value in
                webViewInterface = value
            }
    }
}

#if DEBUG
struct TabletSearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        let model = SearchBarViewModel()
        let state: Binding<SearchBarState> = .init {
            // .viewMode("cotton", "cotton", true)
            .blankSearch
        } set: { _ in
            //
        }
        let interface: Binding<WebViewNavigatable?> = .init {
            nil
        } set: { _ in
            //
        }
        let toolbarModel = WebBrowserToolbarModel()
        // View is jumping when you tap on it
        TabletSearchBarView(model, state, toolbarModel, interface)
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (3rd generation)"))
    }
}
#endif
