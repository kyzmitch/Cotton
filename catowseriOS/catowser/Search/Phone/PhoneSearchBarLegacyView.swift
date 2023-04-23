//
//  PhoneSearchBarLegacyView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/21/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI

struct PhoneSearchBarLegacyView: UIViewControllerRepresentable {
    private weak var searchBarDelegate: UISearchBarDelegate?
    /// Model also has action property
    @Binding private var action: SearchBarAction
    
    init(_ searchBarDelegate: UISearchBarDelegate?,
         _ action: Binding<SearchBarAction>) {
        self.searchBarDelegate = searchBarDelegate
        _action = action
    }
    
    typealias UIViewControllerType = UIViewController
    
    private var vcFactory: ViewControllerFactory {
        ViewsEnvironment.shared.vcFactory
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let vc = vcFactory.deviceSpecificSearchBarViewController(searchBarDelegate)
        // swiftlint:disable:next force_unwrapping
        return vc!.viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        guard let interface = uiViewController as? SearchBarControllerInterface else {
            return
        }
        // Update UIKit search bar view when SwiftUI detects tab content replacement
        // or User taps on Cancel button and it is detected by search bar delegate.
        interface.handleAction(action)
    }
}
