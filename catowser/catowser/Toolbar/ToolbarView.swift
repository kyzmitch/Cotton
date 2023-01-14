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
        /*
         - safeAreaInset(edge: .bottom, spacing: 0)
         Allows to set same color for the space under toolbar
         */
        
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

private struct ToolbarLegacyView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    @Binding private var webViewInterface: WebViewNavigatable?
    
    init(_ webViewInterface: Binding<WebViewNavigatable?>) {
        _webViewInterface = webViewInterface
    }
    
    private var vcFactory: ViewControllerFactory {
        ViewsEnvironment.shared.vcFactory
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let interface = context.environment.browserContentCoordinators
        let vc = vcFactory.toolbarViewController(nil,
                                                 interface?.globalMenuDelegate,
                                                 interface?.toolbarCoordinator,
                                                 interface?.toolbarPresenter)
        // swiftlint:disable:next force_unwrapping
        return vc!
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        guard let vc = uiViewController as? WebBrowserToolbarController<MainToolbarCoordinator> else {
            return
        }
        // This is the only way to set the web view interface for the toolbar
        vc.siteNavigator = webViewInterface
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
