//
//  GlobalMenuCoordinator.swift
//  catowser
//
//  Created by Andrey Ermoshin on 13.11.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit

final class GlobalMenuCoordinator: Coordinator {
    let vcFactory: ViewControllerFactory
    var startedCoordinator: Coordinator?
    weak var parent: CoordinatorOwner?
    var startedVC: AnyViewController?
    var presenterVC: AnyViewController?
    
    /// Data required for start of next navigation
    private let model: SiteMenuModel
    /// View needed when initial screen needs to be shown on Tablet
    private let sourceView: UIView
    /// Rectangle needed when initial screen needs to be shown on Tablet
    private let sourceRect: CGRect
    
    init(_ vcFactory: ViewControllerFactory,
         _ presenter: AnyViewController,
         _ model: SiteMenuModel,
         _ sourceView: UIView,
         _ sourceRect: CGRect) {
        self.vcFactory = vcFactory
        self.presenterVC = presenter
        self.model = model
        self.sourceView = sourceView
        self.sourceRect = sourceRect
    }
    
    func start() {
        let vc = vcFactory.siteMenuViewController(model, self)
        if isPad {
            vc.modalPresentationStyle = .popover
            vc.preferredContentSize = CGSize(width: 400, height: 360)
            if let popoverPresenter = vc.popoverPresentationController {
                // for iPad
                popoverPresenter.sourceView = sourceView
                popoverPresenter.sourceRect = sourceRect
            }
        }
        startedVC = vc
        presenterVC?.viewController.present(vc, animated: true)
    }
}

extension GlobalMenuCoordinator: CoordinatorOwner {
    func didFinish() {
        startedCoordinator = nil
    }
}

enum MenuScreenRoute: Route {
    case initialTabContent
    case tabAddPolicy
    case autocompleteProvider
    case asyncApi
}

extension GlobalMenuCoordinator: Navigating {
    typealias R = MenuScreenRoute
    
    func showNext(_ route: R) {
        
    }
}
