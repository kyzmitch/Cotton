//
//  FilesGreedCoordinator.swift
//  catowser
//
//  Created by Andrei Ermoshin on 11/30/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit

final class FilesGreedCoordinator: Coordinator {
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
        let vc = vcFactory.filesGreedViewController()
        startedVC = vc
        
        guard let containerView = presenterVC?.controllerView else {
            return
        }
        presenterVC?.viewController.add(asChildViewController: vc.viewController, to: containerView)
    }
}
