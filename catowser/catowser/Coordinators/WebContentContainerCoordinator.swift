//
//  WebContentContainerCoordinator.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/1/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit

final class WebContentContainerCoordinator: Coordinator {
    let vcFactory: any ViewControllerFactory
    var startedCoordinator: Coordinator?
    weak var parent: CoordinatorOwner?
    var startedVC: AnyViewController?
    weak var presenterVC: AnyViewController?
    
    /// The view needed to hold tab content like WebView or favorites table view.
    private lazy var containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        return v
    }()
    
    init(_ vcFactory: any ViewControllerFactory,
         _ presenter: AnyViewController) {
        self.vcFactory = vcFactory
        self.presenterVC = presenter
    }
    
    func start() {
        presenterVC?.controllerView.addSubview(containerView)
    }
}

enum ContentContainerPart: SubviewPart {
    case viewDidLoad(NSLayoutYAxisAnchor?)
}

extension WebContentContainerCoordinator: SubviewNavigation {
    typealias SP = ContentContainerPart
    
    func insertNext(_ subview: SP) {
        switch subview {
        case .viewDidLoad(let topAnchor):
            viewDidLoad(topAnchor)
        }
    }
}

private extension WebContentContainerCoordinator {
    func viewDidLoad(_ topAnchor: NSLayoutYAxisAnchor?) {
        // Need to have not simple view controller view but container view
        // to have ability to insert to it and show view controller with
        // bookmarks in case if search bar has no any address entered or
        // webpage controller with web view if some address entered in search bar
        
        guard let controllerView = presenterVC?.controllerView else {
            return
        }
        
        containerView.leadingAnchor.constraint(equalTo: controllerView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: controllerView.trailingAnchor).isActive = true
        
        if isPad {
            containerView.bottomAnchor.constraint(equalTo: controllerView.bottomAnchor).isActive = true
        } else {
            guard let anchor = topAnchor else {
                return
            }
            containerView.bottomAnchor.constraint(equalTo: anchor).isActive = true
        }
    }
}
