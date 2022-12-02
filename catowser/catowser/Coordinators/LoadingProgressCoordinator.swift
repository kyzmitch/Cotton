//
//  LoadingProgressCoordinator.swift
//  catowser
//
//  Created by Andrei Ermoshin on 11/22/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit

final class LoadingProgressCoordinator: Coordinator {
    let vcFactory: any ViewControllerFactory
    var startedCoordinator: Coordinator?
    weak var parent: CoordinatorOwner?
    var startedVC: AnyViewController?
    weak var presenterVC: AnyViewController?
    
    private var hiddenWebLoadConstraint: NSLayoutConstraint?
    private var showedWebLoadConstraint: NSLayoutConstraint?
    
    init(_ vcFactory: any ViewControllerFactory,
         _ presenter: AnyViewController) {
        self.vcFactory = vcFactory
        self.presenterVC = presenter
    }
    
    func start() {
        guard let containerView = presenterVC?.controllerView else {
            return
        }
        let vc = vcFactory.loadingProgressViewController
        startedVC = vc
        presenterVC?.viewController.add(asChildViewController: vc.viewController, to: containerView)
        hiddenWebLoadConstraint = vc.controllerView.heightAnchor.constraint(equalToConstant: 0)
        showedWebLoadConstraint = vc.controllerView.heightAnchor.constraint(equalToConstant: 6)
        hiddenWebLoadConstraint?.isActive = true
        
        vc.controllerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        vc.controllerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
    }
}

enum LoadingProgressRoute: Route {
    case setProgress(Float, _ animated: Bool)
    case showProgress(Bool)
}

extension LoadingProgressCoordinator: Navigating {
    typealias R = LoadingProgressRoute
    
    func showNext(_ route: R) {
        switch route {
        case .setProgress(let progress, let isAnimated):
            guard let webLoadProgressView = startedVC?.controllerView as? UIProgressView else {
                return
            }
            webLoadProgressView.setProgress(progress, animated: isAnimated)
        case .showProgress(let show):
            if show {
                hiddenWebLoadConstraint?.isActive = false
                showedWebLoadConstraint?.isActive = true
            } else {
                showedWebLoadConstraint?.isActive = false
                hiddenWebLoadConstraint?.isActive = true
            }
        }
    }
}

enum LoadingProgressPart: SubviewPart {}

extension LoadingProgressCoordinator: Layouting {
    typealias SP = LoadingProgressPart
    
    func insertNext(_ subview: SP) {}
    
    func layout(_ step: OwnLayoutStep) {
        switch step {
        case .viewDidLoad(let topAnchor, _):
            viewDidLoad(topAnchor)
        default:
            break
        }
    }
    
    func layoutNext(_ step: LayoutStep<SP>) {
        
    }
}

private extension LoadingProgressCoordinator {
    func viewDidLoad(_ topAnchor: NSLayoutYAxisAnchor?) {
        guard let webLoadProgressView = startedVC?.controllerView,
              let containerView = presenterVC?.controllerView else {
            return
        }
        guard let anchor = topAnchor else {
            return
        }
        webLoadProgressView.topAnchor.constraint(equalTo: anchor).isActive = true
        containerView.topAnchor.constraint(equalTo: webLoadProgressView.bottomAnchor).isActive = true
    }
}
