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
    }
}

enum LoadingProgressPart: SubviewPart {
    case setProgress(Float, _ animated: Bool)
}

extension LoadingProgressCoordinator: SubviewNavigation {
    typealias SP = LoadingProgressPart
    
    func insertNext(_ subview: SP) {
        switch subview {
        case .setProgress(let progress, let isAnimated):
            guard let webLoadProgressView = presenterVC?.controllerView as? UIProgressView else {
                return
            }
            webLoadProgressView.setProgress(progress, animated: isAnimated)
        }
    }
}
