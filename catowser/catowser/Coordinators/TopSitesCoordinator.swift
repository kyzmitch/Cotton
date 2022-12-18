//
//  TopSitesCoordinator.swift
//  catowser
//
//  Created by Andrei Ermoshin on 11/20/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit
import CoreHttpKit
import CoreBrowser
import FeaturesFlagsKit

final class TopSitesCoordinator: Coordinator {
    let vcFactory: ViewControllerFactory
    var startedCoordinator: Coordinator?
    weak var parent: CoordinatorOwner?
    var startedVC: AnyViewController?
    weak var presenterVC: AnyViewController?
    var navigationStack: UINavigationController?
    
    private let contentContainerView: UIView?
    private let uiFramework: UIFrameworkType
    
    init(_ vcFactory: ViewControllerFactory,
         _ presenter: AnyViewController?,
         _ contentContainerView: UIView?) {
        self.vcFactory = vcFactory
        self.presenterVC = presenter
        self.contentContainerView = contentContainerView
        uiFramework = FeatureManager.appUIFrameworkValue()
    }
    
    func start() {
        guard uiFramework == .uiKit else {
            return
        }
        guard let contentContainerView = contentContainerView else {
            return
        }
        let vc = vcFactory.topSitesViewController(self)
        startedVC = vc
        vc.reload(with: DefaultTabProvider.shared.topSites)
        presenterVC?.viewController.add(asChildViewController: vc.viewController, to: contentContainerView)
        
        let topSitesView: UIView = vc.controllerView
        topSitesView.translatesAutoresizingMaskIntoConstraints = false
        topSitesView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor).isActive = true
        topSitesView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor).isActive = true
        topSitesView.topAnchor.constraint(equalTo: contentContainerView.topAnchor).isActive = true
        topSitesView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor).isActive = true
    }
}

enum TopSitesRoute: Route {
    case select(Site)
}

extension TopSitesCoordinator: Navigating {
    typealias R = TopSitesRoute
    
    func showNext(_ route: R) {
        switch route {
        case .select(let site):
            // Open selected top site
            try? TabsListManager.shared.replaceSelected(tabContent: .site(site))
        }
    }
    
    func stop() {
        guard uiFramework == .uiKit else {
            return
        }
        startedVC?.viewController.removeFromChild()
        parent?.coordinatorDidFinish(self)
    }
}
