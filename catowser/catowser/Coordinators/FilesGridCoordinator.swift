//
//  FilesGridCoordinator.swift
//  catowser
//
//  Created by Andrei Ermoshin on 11/30/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit

final class FilesGridCoordinator: Coordinator {
    let vcFactory: any ViewControllerFactory
    var startedCoordinator: Coordinator?
    weak var parent: CoordinatorOwner?
    var startedVC: AnyViewController?
    weak var presenterVC: AnyViewController?
    
    private var filesGreedHeightConstraint: NSLayoutConstraint?
    private var hiddenFilesGreedConstraint: NSLayoutConstraint?
    
    init(_ vcFactory: any ViewControllerFactory,
         _ presenter: AnyViewController) {
        self.vcFactory = vcFactory
        self.presenterVC = presenter
    }
    
    func start() {
        let vc = vcFactory.filesGridViewController()
        startedVC = vc
        
        guard !isPad else {
            // use popover presentation on tablets
            return
        }
        guard let containerView = presenterVC?.controllerView else {
            return
        }
        presenterVC?.viewController.add(asChildViewController: vc.viewController, to: containerView)
    }
}

enum FilesGridPart: SubviewPart {
    case viewDidLoad
    case viewDidLayoutSubviews(CGFloat)
}

extension FilesGridCoordinator: SubviewNavigation {
    typealias SP = FilesGridPart
    
    func insertNext(_ subview: SP) {
        switch subview {
        case .viewDidLoad:
            viewDidLoad()
        case .viewDidLayoutSubviews(let containerHeight):
            viewDidLayoutSubviews(containerHeight)
        }
    }
}

private extension FilesGridCoordinator {
    func viewDidLoad() {
        guard !isPad else {
            return
        }
        
        guard let filesView: UIView = startedVC?.controllerView else {
            return
        }
        guard let containerView = presenterVC?.controllerView else {
            return
        }
        filesView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        filesView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        // temporarily use 0 height because actual height of free space is
        // unknown at the moment
        let greedHeight: CGFloat = 0
        hiddenFilesGreedConstraint = filesView.bottomAnchor.constraint(equalTo: tagsView.topAnchor,
                                                                                   constant: greedHeight)
        layoutCoordinator.showedFilesGreedConstraint = filesView.bottomAnchor.constraint(equalTo: tagsView.topAnchor)
        filesGreedHeightConstraint = filesView.heightAnchor.constraint(equalToConstant: greedHeight)
        hiddenFilesGreedConstraint?.isActive = true
        filesGreedHeightConstraint?.isActive = true
    }
    
    func viewDidLayoutSubviews(_ containerHeight: CGFloat) {
        guard !isPad else {
            return
        }
        
        let freeHeight: CGFloat = containerHeight - .linkTagsHeight
        
        filesGreedHeightConstraint?.constant = freeHeight
        layoutCoordinator.hiddenFilesGreedConstraint?.constant = freeHeight
        startedVC?.controllerView.setNeedsLayout()
        startedVC?.controllerView.layoutIfNeeded()
    }
}
