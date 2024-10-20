//
//  TopSitesCoordinator.swift
//  catowser
//
//  Created by Andrei Ermoshin on 11/20/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import UIKit
import CottonBase
import CoreBrowser
import FeaturesFlagsKit

@MainActor
final class TopSitesCoordinator: Coordinator {
    let vcFactory: ViewControllerFactory
    var startedCoordinator: Coordinator?
    weak var parent: CoordinatorOwner?
    var startedVC: AnyViewController?
    weak var presenterVC: AnyViewController?
    var navigationStack: UINavigationController?

    private let contentContainerView: UIView?
    let uiFramework: UIFrameworkType

    init(_ vcFactory: ViewControllerFactory,
         _ presenter: AnyViewController?,
         _ contentContainerView: UIView?,
         _ uiFramework: UIFrameworkType) {
        self.vcFactory = vcFactory
        self.presenterVC = presenter
        self.contentContainerView = contentContainerView
        self.uiFramework = uiFramework
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
        /// Async start should be fine here, because layout is in the same closure
        Task {
            let isJsEnabled = await FeatureManager.shared.boolValue(of: .javaScriptEnabled)
            vc.reload(with: await DefaultTabProvider.shared.topSites(isJsEnabled))
            presenterVC?.viewController.add(asChildViewController: vc.viewController, to: contentContainerView)

            let topSitesView: UIView = vc.controllerView
            topSitesView.translatesAutoresizingMaskIntoConstraints = false
            topSitesView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor).isActive = true
            topSitesView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor).isActive = true
            topSitesView.topAnchor.constraint(equalTo: contentContainerView.topAnchor).isActive = true
            topSitesView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor).isActive = true
        }
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
            /// TODO: Usually it would be a view model responsibility and not coordinator
            Task {
                _ = await TabsDataService.shared.sendCommand(.replaceSelectedContent(.site(site)))
            }
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
