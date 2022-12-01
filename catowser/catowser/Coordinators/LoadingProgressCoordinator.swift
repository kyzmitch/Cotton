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

enum LoadingProgressPart: SubviewPart {
    case viewDidLoad(NSLayoutYAxisAnchor)
    case setProgress(Float, _ animated: Bool)
    case showProgress(Bool)
}

extension LoadingProgressCoordinator: SubviewNavigation {
    typealias SP = LoadingProgressPart
    
    func insertNext(_ subview: SP) {
        switch subview {
        case .viewDidLoad(let sbViewBottomAnchor):
            guard let webLoadProgressView = startedVC?.controllerView,
                  let containerView = presenterVC?.controllerView else {
                return
            }
            webLoadProgressView.topAnchor.constraint(equalTo: sbViewBottomAnchor).isActive = true
            containerView.topAnchor.constraint(equalTo: webLoadProgressView.bottomAnchor).isActive = true
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
