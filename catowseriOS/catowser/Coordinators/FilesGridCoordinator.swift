//
//  FilesGridCoordinator.swift
//  catowser
//
//  Created by Andrei Ermoshin on 11/30/22.
//  Copyright © 2022 Cotton (former Catowser). All rights reserved.
//

import UIKit

final class FilesGridCoordinator: Coordinator {
    let vcFactory: any ViewControllerFactory
    var startedCoordinator: Coordinator?
    weak var parent: CoordinatorOwner?
    var startedVC: AnyViewController?
    weak var presenterVC: AnyViewController?
    var navigationStack: UINavigationController?

    private var filesGreedHeightConstraint: NSLayoutConstraint?
    private var hiddenFilesGreedConstraint: NSLayoutConstraint?
    private var showedFilesGreedConstraint: NSLayoutConstraint?

    private(set) var isFilesGreedShowed: Bool = false
    private weak var interface: FilesGridPresenter?

    init(_ vcFactory: any ViewControllerFactory,
         _ presenter: AnyViewController?,
         _ navigationStack: UINavigationController?) {
        self.vcFactory = vcFactory
        self.presenterVC = presenter
        self.navigationStack = navigationStack
    }

    func start() {
        let vc = vcFactory.filesGridViewController()
        interface = vc
        startedVC = vc

        guard !isPad else {
            // use popover presentation on tablets
            return
        }
        guard let superView = presenterVC?.controllerView else {
            return
        }
        presenterVC?.viewController.add(asChildViewController: vc.viewController, to: superView)
    }
}

enum FilesGridRoute: Route {
    case hide
    case clear
    case show(LinksType, UIView, CGRect, TagsSiteDataSource)
}

extension FilesGridCoordinator: Navigating {
    typealias R = FilesGridRoute

    func showNext(_ route: R) {
        switch route {
        case .hide:
            hide()
        case .clear:
            clear()
        case .show(let type, let sourceView, let sourceRect, let tagsDataSource):
            showVideos(type, sourceView, sourceRect, tagsDataSource)
        }
    }

    // `stop` is not needed, it can be hid and showed
}

enum FilesGridPart: SubviewPart {}

extension FilesGridCoordinator: Layouting {
    typealias SP = FilesGridPart

    func insertNext(_ subview: SP) {}

    func layout(_ step: OwnLayoutStep) {
        switch step {
        case .viewDidLoad(_, let bottomAnchor, _):
            viewDidLoad(bottomAnchor)
        case .viewDidLayoutSubviews(let containerHeight):
            viewDidLayoutSubviews(containerHeight)
        case .viewSafeAreaInsetsDidChange:
            break
        }
    }

    func layoutNext(_ step: LayoutStep<SP>) {

    }
}

private extension FilesGridCoordinator {
    func viewDidLoad(_ bottomAnchor: NSLayoutYAxisAnchor?) {
        guard !isPad else {
            return
        }
        guard let filesView = startedVC?.controllerView, let superView = presenterVC?.controllerView else {
            return
        }
        guard let bottomViewAnchor = bottomAnchor else {
            return
        }
        filesView.leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
        filesView.trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
        // temporarily use 0 height because actual height of free space is
        // unknown at the moment and will be calculated later (probably based on keyboard height)
        let gridHeight: CGFloat = 0
        hiddenFilesGreedConstraint = filesView.bottomAnchor.constraint(equalTo: bottomViewAnchor, constant: gridHeight)
        showedFilesGreedConstraint = filesView.bottomAnchor.constraint(equalTo: bottomViewAnchor)
        filesGreedHeightConstraint = filesView.heightAnchor.constraint(equalToConstant: gridHeight)
        hiddenFilesGreedConstraint?.isActive = true
        filesGreedHeightConstraint?.isActive = true
    }

    func viewDidLayoutSubviews(_ containerHeight: CGFloat?) {
        guard !isPad, let containerHeight = containerHeight else {
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
        if isPad {
            navigationStack?.popViewController(animated: true)
        } else {
            showedFilesGreedConstraint?.isActive = false
            hiddenFilesGreedConstraint?.isActive = true
            startedVC?.controllerView.layoutIfNeeded()
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
        if isPad {
            guard let vc = startedVC?.viewController else {
                return
            }
            interface?.reloadWith(source: tagsDataSource, completion: nil)
            navigationStack?.preferredContentSize = CGSize(width: 500, height: 600)
            navigationStack?.pushViewController(vc, animated: true)
        } else {
            interface?.reloadWith(source: tagsDataSource) { [weak self] in
                self?.showFilesGreedOnPhoneIfNeeded()
            }
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
