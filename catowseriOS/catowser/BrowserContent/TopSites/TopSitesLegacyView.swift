//
//  TopSitesLegacyView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/23/23.
//  Copyright © 2023 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import SwiftUI
import UIKit

struct TopSitesLegacyView: CatowserUIVCRepresentable {
    private let vm: TopSitesViewModel
    typealias UIViewControllerType = UIViewController
    
    init(_ vm: TopSitesViewModel) {
        self.vm = vm
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let interface = context.environment.browserContentCoordinators
        let vc: AnyViewController & TopSitesInterface = vcFactory.topSitesViewController(interface?.topSitesCoordinator)
        vc.reload(with: vm.topSites)
        return vc.viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
