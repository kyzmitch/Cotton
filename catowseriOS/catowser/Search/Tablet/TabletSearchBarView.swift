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
    private weak var searchBarDelegate: UISearchBarDelegate?
    private let toolbarVM: BrowserToolbarViewModel
    @Binding private var action: SearchBarAction
    @Binding private var webViewInterface: WebViewNavigatable?
    private let mode: SwiftUIMode
    
    init(_ searchBarDelegate: UISearchBarDelegate?,
         _ action: Binding<SearchBarAction>,
         _ toolbarVM: BrowserToolbarViewModel,
         _ webViewInterface: Binding<WebViewNavigatable?>,
         _ mode: SwiftUIMode) {
        self.searchBarDelegate = searchBarDelegate
        self.toolbarVM = toolbarVM
        _action = action
        _webViewInterface = webViewInterface
        self.mode = mode
    }
    
    var body: some View {
        switch mode {
        case .compatible:
            TabletSearchBarLegacyView(searchBarDelegate, $action, $webViewInterface)
                .frame(height: CGFloat.searchViewHeight)
                .onReceive(toolbarVM.$webViewInterface) { value in
                    webViewInterface = value
                }
        case .full:
            Spacer()
        }
    }
}

#if DEBUG
struct TabletSearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        let searchBarDelegate: UISearchBarDelegate? = nil
        let state: Binding<SearchBarAction> = .init {
            .updateView("cotton", "cotton")
        } set: { _ in
            //
        }
        let interface: Binding<WebViewNavigatable?> = .init {
            nil
        } set: { _ in
            //
        }
        let toolbarVM = BrowserToolbarViewModel()
        // View is jumping when you tap on it
        TabletSearchBarView(searchBarDelegate, state, toolbarVM, interface, .compatible)
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (3rd generation)"))
    }
}
#endif
