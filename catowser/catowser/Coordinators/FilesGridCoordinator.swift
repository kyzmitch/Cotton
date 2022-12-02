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
    private var showedFilesGreedConstraint: NSLayoutConstraint?
    
    private(set) var isFilesGreedShowed: Bool = false
    private weak var interface: FilesGridPresenter?
    
    init(_ vcFactory: any ViewControllerFactory,
         _ presenter: AnyViewController) {
        self.vcFactory = vcFactory
        self.presenterVC = presenter
    }
    
    func start() {
        let vc = vcFactory.filesGridViewController()
        interface = vc
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

enum FilesGridRoute: Route {
    case hide
    case clear
    case videos(LinksType, UIView, CGRect, TagsSiteDataSource)
}

extension FilesGridCoordinator: Navigating {
    typealias R = FilesGridRoute
    
    func showNext(_ route: R) {
        switch route {
        case .hide:
            hide()
        case .clear:
            clear()
        case .videos(let type, let sourceView, let sourceRect, let tagsDataSource):
            showVideos(type, sourceView, sourceRect, tagsDataSource)
        }
    }
    
    func stop() {
        // TODO: remove from parent view controller
    }
}

enum FilesGridPart: SubviewPart {}

extension FilesGridCoordinator: Layouting {
    typealias SP = FilesGridPart
    
    func insertNext(_ subview: SP) {}
    
    func layout(_ step: OwnLayoutStep) {
        switch step {
        case .viewDidLoad(_, let bottomAnchor):
            guard let anchor = bottomAnchor else {
                return
            }
            viewDidLoad(anchor)
        case .viewDidLayoutSubviews(let containerHeight):
            guard let height = containerHeight else {
                return
            }
            viewDidLayoutSubviews(height)
        case .viewSafeAreaInsetsDidChange:
            break
        }
    }
    
    func layoutNext(_ step: LayoutStep<SP>) {
        
    }
}

private extension FilesGridCoordinator {
    func viewDidLoad(_ bottomAnchor: NSLayoutYAxisAnchor) {
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
        hiddenFilesGreedConstraint = filesView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: greedHeight)
        showedFilesGreedConstraint = filesView.bottomAnchor.constraint(equalTo: bottomAnchor)
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
        hiddenFilesGreedConstraint?.constant = freeHeight
        startedVC?.controllerView.setNeedsLayout()
        startedVC?.controllerView.layoutIfNeeded()
    }
    
    func hide() {
        guard isFilesGreedShowed else {
            return
        }
        isFilesGreedShowed = false
        if !isPad {
            showedFilesGreedConstraint?.isActive = false
            hiddenFilesGreedConstraint?.isActive = true

            startedVC?.controllerView.layoutIfNeeded()
        } else {
            startedVC?.viewController.dismiss(animated: true, completion: nil)
        }
    }
    
    func clear() {
        interface?.clearFiles()
    }
    
    func showVideos(_ type: LinksType,
                    _ sourceView: UIView,
                    _ sourceRect: CGRect,
                    _ tagsDataSource: TagsSiteDataSource) {
        guard !isFilesGreedShowed else {
            showNext(.hide)
            return
        }
        if !isPad {
            interface?.reloadWith(source: tagsDataSource) { [weak self] in
                self?.showFilesGreedOnPhoneIfNeeded()
            }
        } else {
            guard let vc = startedVC?.viewController else {
                return
            }
            vc.modalPresentationStyle = .popover
            vc.preferredContentSize = CGSize(width: 500, height: 600)
            if let popoverPresenter = vc.popoverPresentationController {
                popoverPresenter.permittedArrowDirections = .any
                popoverPresenter.sourceRect = sourceRect
                popoverPresenter.sourceView = sourceView
            }
            interface?.reloadWith(source: tagsDataSource, completion: nil)
            presenterVC?.viewController.present(vc, animated: true, completion: nil)
        }
    }
    
    /// Shows files greed view, designed only for Phone layout
    /// for Tablet layout we're using popover.
    func showFilesGreedOnPhoneIfNeeded() {
        guard !isPad else {
            // only for Phone layout
            return
        }
        guard !isFilesGreedShowed else {
            return
        }
        isFilesGreedShowed = true

        hiddenFilesGreedConstraint?.isActive = false
        showedFilesGreedConstraint?.isActive = true

        UIView.animate(withDuration: 0.6) {
            self.startedVC?.controllerView.layoutIfNeeded()
        }
    }
}
