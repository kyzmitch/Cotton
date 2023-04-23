//
//  TopSitesLegacyView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/23/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI
import UIKit

struct TopSitesLegacyView: UIViewControllerRepresentable {
    let model: TopSitesModel
    typealias UIViewControllerType = UIViewController
    
    private var vcFactory: ViewControllerFactory {
        ViewsEnvironment.shared.vcFactory
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let interface = context.environment.browserContentCoordinators
        let vc: AnyViewController & TopSitesInterface = vcFactory.topSitesViewController(interface?.topSitesCoordinator)
        vc.reload(with: model.topSites)
        return vc.viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
