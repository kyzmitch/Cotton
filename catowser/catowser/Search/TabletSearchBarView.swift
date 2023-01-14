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
    @Binding private var stateBinding: SearchBarState
    private(set) var toolbarModel: WebBrowserToolbarModel
    @Binding private var webViewInterface: WebViewNavigatable?
    
    init(_ model: SearchBarViewModel,
         _ stateBinding: Binding<SearchBarState>,
         _ toolbarModel: WebBrowserToolbarModel,
         _ webViewInterface: Binding<WebViewNavigatable?>) {
        self.model = model
        _stateBinding = stateBinding
        self.toolbarModel = toolbarModel
        _webViewInterface = webViewInterface
    }
    
    var body: some View {
        TabletSearchBarLegacyView(model, $stateBinding, $webViewInterface)
            .frame(height: CGFloat.searchViewHeight)
            .onReceive(toolbarModel.$webViewInterface) { value in
                webViewInterface = value
            }
    }
}

private struct TabletSearchBarLegacyView: UIViewControllerRepresentable {
    private var model: SearchBarViewModel
    @Binding private var stateBinding: SearchBarState
    @Binding private var webViewInterface: WebViewNavigatable?
    
    init(_ model: SearchBarViewModel,
         _ stateBinding: Binding<SearchBarState>,
         _ webViewInterface: Binding<WebViewNavigatable?>) {
        self.model = model
        _stateBinding = stateBinding
        _webViewInterface = webViewInterface
    }
    
    typealias UIViewControllerType = UIViewController
    
    private var vcFactory: ViewControllerFactory {
        ViewsEnvironment.shared.vcFactory
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let interface = context.environment.browserContentCoordinators
        let vc = vcFactory.deviceSpecificSearchBarViewController(model, nil, interface?.globalMenuDelegate)
        // swiftlint:disable:next force_unwrapping
        return vc!.viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        if let interface = uiViewController as? SearchBarControllerInterface {
            interface.changeState(to: stateBinding)
        }
        
        if let vc = uiViewController as? TabletSearchBarViewController {
            // This is the only way to set the web view interface for the tablet toolbar
            vc.siteNavigator = webViewInterface
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
