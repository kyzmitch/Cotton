//
//  TabletSearchBarLegacyView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/21/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI

struct TabletSearchBarLegacyView: UIViewControllerRepresentable {
    private weak var searchBarDelegate: UISearchBarDelegate?
    @Binding private var action: SearchBarAction
    @Binding private var webViewInterface: WebViewNavigatable?
    
    init(_ searchBarDelegate: UISearchBarDelegate?,
         _ action: Binding<SearchBarAction>,
         _ webViewInterface: Binding<WebViewNavigatable?>) {
        self.searchBarDelegate = searchBarDelegate
        _action = action
        _webViewInterface = webViewInterface
    }
    
    typealias UIViewControllerType = UIViewController
    
    private var vcFactory: ViewControllerFactory {
        ViewsEnvironment.shared.vcFactory
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let interface = context.environment.browserContentCoordinators
        let vc = vcFactory.deviceSpecificSearchBarViewController(searchBarDelegate, nil, interface?.globalMenuDelegate)
        // swiftlint:disable:next force_unwrapping
        return vc!.viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        if let interface = uiViewController as? SearchBarControllerInterface {
            // Update UIKit search bar view when SwiftUI detects tab content replacement
            // or User taps on Cancel button and it is detected by search bar delegate.
            interface.handleAction(action)
        }
        
        if let vc = uiViewController as? TabletSearchBarViewController {
            // This is the only way to set the web view interface for the tablet toolbar
            vc.siteNavigator = webViewInterface
        }
    }
}