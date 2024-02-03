//
//  TabletTabsLegacyView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/26/23.
//  Copyright © 2023 Cotton (former Catowser). All rights reserved.
//

import SwiftUI

struct TabletTabsLegacyView: CatowserUIVCRepresentable {
    typealias UIViewControllerType = UIViewController
    
    private let viewModel: AllTabsViewModel
    
    init(_ viewModel: AllTabsViewModel) {
        self.viewModel = viewModel
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let vc = vcFactory.tabsViewController(viewModel)
        // swiftlint:disable:next force_unwrapping
        return vc!.viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
