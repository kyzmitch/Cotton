//
//  GlobalMenuCoordinator.swift
//  catowser
//
//  Created by Andrey Ermoshin on 13.11.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit

enum MenuScreenRoute: Route {
    case initialTabContent
    case tabAddPolicy
    case autocompleteProvider
    case asyncApi
}

final class GlobalMenuCoordinator: Coordinator {
    typealias R = MenuScreenRoute
    
    let vcFactory: any ViewControllerFactory
    var startedCoordinator: (any Coordinator)?
    weak var parent: CoordinatorOwner?
    /// View controller which is currently visible
    private let presenter: any AnyViewController
    /// Data required for start of next navigation
    private let model: SiteMenuModel
    /// View needed when initial screen needs to be shown on Tablet
    private let sourceView: UIView
    /// Rectangle needed when initial screen needs to be shown on Tablet
    private let sourceRect: CGRect
    
    init(_ vcFactory: any ViewControllerFactory,
         _ presenter: any AnyViewController,
         _ model: SiteMenuModel,
         _ sourceView: UIView,
         _ sourceRect: CGRect) {
        self.vcFactory = vcFactory
        self.presenter = presenter
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
        presenter.viewController.present(vc, animated: true)
    }
    
    func showNext(_ route: R) {
        
    }
}

extension GlobalMenuCoordinator: CoordinatorOwner {
    func didFinish() {
        startedCoordinator = nil
    }
}
