//
//  TabletSearchBarLegacyView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/21/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI

struct TabletSearchBarLegacyView: UIViewControllerRepresentable {
    private var model: SearchBarViewModel
    @Binding private var state: SearchBarState
    @Binding private var webViewInterface: WebViewNavigatable?
    
    init(_ model: SearchBarViewModel,
         _ state: Binding<SearchBarState>,
         _ webViewInterface: Binding<WebViewNavigatable?>) {
        self.model = model
        _state = state
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
            interface.changeState(to: state)
        }
        
        if let vc = uiViewController as? TabletSearchBarViewController {
            // This is the only way to set the web view interface for the tablet toolbar
            vc.siteNavigator = webViewInterface
        }
    }
}
