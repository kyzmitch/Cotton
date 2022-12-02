//
//  TabletTabsCoordinator.swift
//  catowser
//
//  Created by Andrei Ermoshin on 11/28/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation

final class TabletTabsCoordinator: Coordinator {
    let vcFactory: any ViewControllerFactory
    var startedCoordinator: Coordinator?
    var parent: CoordinatorOwner?
    var startedVC: AnyViewController?
    var presenterVC: AnyViewController?
    
    init(_ vcFactory: any ViewControllerFactory,
         _ presenter: AnyViewController) {
        self.vcFactory = vcFactory
        self.presenterVC = presenter
    }
    
    func start() {
        guard let vc = vcFactory.tabsViewController(), let containerView = presenterVC?.controllerView else {
            return
        }
        startedVC = vc
        
        presenterVC?.viewController.add(asChildViewController: vc.viewController, to: containerView)
        vc.controllerView.translatesAutoresizingMaskIntoConstraints = false
    }
}

enum TabletTabsSubview: SubviewPart {}

extension TabletTabsCoordinator: Layouting {
    typealias SP = TabletTabsSubview
    
    func insertNext(_ subview: SP) {}
    
    func layout(_ step: OwnLayoutStep) {
        switch step {
        case .viewDidLoad:
            viewDidLoad()
        default:
            break
        }
    }
    
    func layoutNext(_ step: LayoutStep<SP>) {}
}

private extension TabletTabsCoordinator {
    func viewDidLoad() {
        guard let vc = startedVC, let containerView = presenterVC?.controllerView else {
            return
        }
        // https://github.com/SnapKit/SnapKit/issues/448
        // https://developer.apple.com/documentation/uikit/uiviewcontroller/1621367-toplayoutguide
        // https://developer.apple.com/documentation/uikit/uiview/2891102-safearealayoutguide
        if #available(iOS 11, *) {
            let topAnchor = containerView.safeAreaLayoutGuide.topAnchor
            vc.controllerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        } else {
            vc.controllerView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        }
        vc.controllerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        vc.controllerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        vc.controllerView.heightAnchor.constraint(equalToConstant: .tabHeight).isActive = true
    }
}
