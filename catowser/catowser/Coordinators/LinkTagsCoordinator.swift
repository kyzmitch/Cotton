//
//  LinkTagsCoordinator.swift
//  catowser
//
//  Created by Andrei Ermoshin on 11/28/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit
import JSPlugins

final class LinkTagsCoordinator: Coordinator {
    let vcFactory: any ViewControllerFactory
    var startedCoordinator: Coordinator?
    weak var parent: CoordinatorOwner?
    var startedVC: AnyViewController?
    weak var presenterVC: AnyViewController?
    
    // MARK: - state properties
    
    /// Specific coordinator type
    private var filesGreedCoordinator: FilesGreedCoordinator?
    
    private var tagsSiteDataSource: TagsSiteDataSource?
    private(set) var isFilesGreedShowed: Bool = false
    private weak var viewInterface: LinkTagsPresenter?
    
    // MARK: - All constraints should be stored by strong references because they are removed during deactivation

    var hiddenTagsConstraint: NSLayoutConstraint?
    var showedTagsConstraint: NSLayoutConstraint?
    
    // MARK: - init and start
    
    init(_ vcFactory: any ViewControllerFactory,
         _ presenter: AnyViewController) {
        self.vcFactory = vcFactory
        self.presenterVC = presenter
    }
    
    func start() {
        let vc = vcFactory.linkTagsViewController(self)
        vc.controllerView.translatesAutoresizingMaskIntoConstraints = false
        startedVC = vc
        viewInterface = vc
        
        guard let containerView = presenterVC?.controllerView else {
            return
        }
        presenterVC?.viewController.add(asChildViewController: vc.viewController, to: containerView)
    }
}

extension LinkTagsCoordinator: CoordinatorOwner {}

enum LinkTagsPart: SubviewPart {
    /// Link type and source view
    case showVideos(LinksType, UIView)
    case openInstagramTags([InstagramVideoNode])
    case openHtmlTags([HTMLVideoTag])
    case closeTags
    case insertFilesGreed
    case startLayout(NSLayoutYAxisAnchor)
}

extension LinkTagsCoordinator: SubviewNavigation {
    typealias SP = LinkTagsPart
    
    func insertNext(_ subview: SP) {
        switch subview {
        case .showVideos(let type, let sourceView):
            presentVideos(type, sourceView)
        case .openInstagramTags(let tags):
            openTagsFor(instagram: tags)
        case .openHtmlTags(let tags):
            openTagsFor(html: tags)
        case .closeTags:
            closeTags()
        case .insertFilesGreed:
            startFilesGreed()
        case .startLayout(let topAnchor):
            startLayout(topAnchor)
        }
    }
}

private extension LinkTagsCoordinator {
    func startLayout(_ topAnchor: NSLayoutYAxisAnchor) {
        guard let tagsView = startedVC?.controllerView, let containerView = presenterVC?.controllerView else {
            return
        }
        if isPad {
            let tagsBottom = tagsView.bottomAnchor
            tagsBottom.constraint(equalTo: topAnchor).isActive = true
        } else {
            hiddenTagsConstraint = tagsView.bottomAnchor.constraint(equalTo: topAnchor, constant: .linkTagsHeight)
            showedTagsConstraint = tagsView.bottomAnchor.constraint(equalTo: topAnchor)
        }
        hiddenTagsConstraint?.isActive = true
        
        tagsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        tagsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        tagsView.heightAnchor.constraint(equalToConstant: .linkTagsHeight).isActive = true
    }
    
    func startFilesGreed() {
        // Using root view controller as a presenter
        // for this specific coordinator, not currently started view controller
        
        // swiftlint:disable:next force_unwrapping
        let presenter = presenterVC!
        let coordinator: FilesGreedCoordinator = .init(vcFactory, presenter)
        coordinator.parent = self
        coordinator.start()
        filesGreedCoordinator = coordinator
    }
    
    func presentVideos(_ type: LinksType, _ sourceView: UIView) {
        guard !isFilesGreedShowed else {
            hideFilesGreedIfNeeded()
            return
        }
        if !isPad {
            filesGreedController.reloadWith(source: source) { [weak self] in
                self?.showFilesGreedOnPhoneIfNeeded()
            }
        } else {
            filesGreedController.viewController.modalPresentationStyle = .popover
            filesGreedController.viewController.preferredContentSize = CGSize(width: 500, height: 600)
            if let popoverPresenter = filesGreedController.viewController.popoverPresentationController {
                popoverPresenter.permittedArrowDirections = .any
                popoverPresenter.sourceRect = sourceRect
                popoverPresenter.sourceView = sourceView
            }
            filesGreedController.reloadWith(source: source, completion: nil)
            presenter.viewController.present(filesGreedController.viewController,
                                             animated: true,
                                             completion: nil)
        }
    }
    
    func openTagsFor(instagram nodes: [InstagramVideoNode]) {
        tagsSiteDataSource = .instagram(nodes)
        viewInterface?.setLinks(nodes.count, for: .video)
        updateDownloadsViews()
    }

    func openTagsFor(html tags: [HTMLVideoTag]) {
        tagsSiteDataSource = .htmlVideos(tags)
        viewInterface?.setLinks(tags.count, for: .video)
        updateDownloadsViews()
    }

    func closeTags() {
        tagsSiteDataSource = nil
        hideFilesGreedIfNeeded()
        hideLinkTagsController()
        filesGreedController.clearFiles()
        viewInterface?.clearLinks()
    }
    
    func hideFilesGreedIfNeeded() {
        guard isFilesGreedShowed else {
            return
        }

        if !isPad {
            showedFilesGreedConstraint?.isActive = false
            hiddenFilesGreedConstraint?.isActive = true

            filesGreedController.controllerView.layoutIfNeeded()
        } else {
            filesGreedController.viewController.dismiss(animated: true, completion: nil)
        }

        isFilesGreedShowed = false
    }
    
    func hideLinkTagsController() {
        guard isLinkTagsShowed else {
            return
        }
        showedTagsConstraint?.isActive = false
        hiddenTagsConstraint?.isActive = true

        // linkTagsController.controllerView.layoutIfNeeded()
        isLinkTagsShowed = false
    }
    
    func updateDownloadsViews() {
        if isPad {
            mediaLinksPresenter?.didReceiveMediaLinks()
        } else {
            showLinkTagsControllerIfNeeded()
        }
    }
    
    func showLinkTagsControllerIfNeeded() {
        guard !isLinkTagsShowed else {
            return
        }

        isLinkTagsShowed = true
        // Order of disabling/enabling is important to not to cause errors in layout calculation.
        hiddenTagsConstraint?.isActive = false
        showedTagsConstraint?.isActive = true

        UIView.animate(withDuration: 0.33) {
            // self.linkTagsController.controllerView.layoutIfNeeded()
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

        hiddenFilesGreedConstraint?.isActive = false
        showedFilesGreedConstraint?.isActive = true

        UIView.animate(withDuration: 0.6) {
            self.filesGreedController.controllerView.layoutIfNeeded()
        }

        isFilesGreedShowed = true
    }
}

extension LinkTagsCoordinator: LinkTagsDelegate {
    func didSelect(type: LinksType, from sourceView: UIView) {
        insertNext(.showVideos(type, sourceView))
    }
}

extension LinkTagsCoordinator: DonwloadPanelDelegate {
    func didPressDownloads(to hide: Bool) {
        if hide {
            hideFilesGreedIfNeeded()
            hideLinkTagsController()
        } else {
            // only can be used for phone layout
            // for table need to use `didPressTabletLayoutDownloads`
            updateDownloadsViews()
        }
    }
    
    func didPressTabletLayoutDownloads(from sourceView: UIView, and sourceRect: CGRect) {
        guard let source = tagsSiteDataSource else { return }
        presentVideoViews(using: source, from: sourceView, and: sourceRect)
    }
}
