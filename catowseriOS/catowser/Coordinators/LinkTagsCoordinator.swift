//
//  LinkTagsCoordinator.swift
//  catowser
//
//  Created by Andrei Ermoshin on 11/28/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import UIKit
import CottonPlugins

/// An interface only needed on Tablet layout, tablet's search bar implements it
protocol MediaLinksPresenter: AnyObject {
    func didReceiveMediaLinks()
    /// Returns source view and rectangle (could be a download arrow button)
    var downloadsPopoverStartInfo: (UIView, CGRect) { get }
}

/// Must inherit from NSObject to implement `UINavigationControllerDelegate`
final class LinkTagsCoordinator: NSObject, Coordinator {
    let vcFactory: any ViewControllerFactory
    var startedCoordinator: Coordinator?
    weak var parent: CoordinatorOwner?
    var startedVC: AnyViewController?
    weak var presenterVC: AnyViewController?
    var navigationStack: UINavigationController?
    
    // MARK: - state properties
    
    /// Specific coordinator type
    private var filesGridCoordinator: FilesGridCoordinator?
    private var isLinkTagsShowed: Bool = false
    
    private var tagsSiteDataSource: TagsSiteDataSource?
    private weak var linkTagsPresenter: LinkTagsPresenter?
    /// Needs to be set outside of init, so, it is not private
    weak var mediaLinksPresenter: MediaLinksPresenter?
    
    // All constraints should be stored by strong references because they are removed during deactivation

    private var hiddenTagsConstraint: NSLayoutConstraint?
    private var showedTagsConstraint: NSLayoutConstraint?
    
    // MARK: - init and start
    
    /// @param presenter is only needed for Phony layout, Tablet layout should use search bar view controller
    init(_ vcFactory: any ViewControllerFactory,
         _ presenter: AnyViewController) {
        self.vcFactory = vcFactory
        self.presenterVC = presenter
        super.init()
        // Using self before end of initializer
        let vc = vcFactory.linkTagsViewController(self)
        vc.controllerView.translatesAutoresizingMaskIntoConstraints = false
        startedVC = vc
        linkTagsPresenter = vc
        // Create stack here to set a root and not in show function
        // because it could be called multiple times
        navigationStack = UINavigationController(rootViewController: vc.viewController)
        navigationStack?.delegate = self
    }
    
    func start() {
        guard !isPad else {
            // use popover presentation on tablets
            return
        }
        guard let superView = presenterVC?.controllerView else {
            return
        }
        guard let vc = startedVC else {
            return
        }
        presenterVC?.viewController.add(asChildViewController: vc.viewController, to: superView)
    }
}

enum LinkTagsRoute: Route {
    case openInstagramTags([InstagramVideoNode])
    case openHtmlTags([HTMLVideoTag])
    case closeTags
}

extension LinkTagsCoordinator: Navigating {
    typealias R = LinkTagsRoute
    
    func showNext(_ route: R) {
        switch route {
        case .openInstagramTags(let tags):
            openTagsFor(instagram: tags)
        case .openHtmlTags(let tags):
            openTagsFor(html: tags)
        case .closeTags:
            closeTags()
        }
    }
    
    func stop() {
        filesGridCoordinator?.stop()
        parent?.coordinatorDidFinish(self)
    }
}

extension LinkTagsCoordinator: CoordinatorOwner {
    func coordinatorDidFinish(_ coordinator: Coordinator) {
        if coordinator === filesGridCoordinator {
            filesGridCoordinator = nil
        }
    }
}

enum LinkTagsPart: SubviewPart {
    case filesGrid
}

extension LinkTagsCoordinator: Layouting {
    typealias SP = LinkTagsPart
    
    func insertNext(_ subview: SP) {
        switch subview {
        case .filesGrid:
            insertFilesGrid()
        }
    }
    
    func layout(_ step: OwnLayoutStep) {
        switch step {
        case .viewDidLoad(_, let bottomAnchor, _):
            // link tags view is attached to bottom view (toolbar or superview bottom)
            // and top is not attached, but there is a constant view height
            viewDidLoad(bottomAnchor)
        case .viewDidLayoutSubviews:
            break
        case .viewSafeAreaInsetsDidChange:
            break
        }
    }
    
    func layoutNext(_ step: LayoutStep<SP>) {
        switch step {
        case .viewDidLoad(let subview, _, _, _):
            switch subview {
            case .filesGrid:
                filesGridViewDidLoad()
            }
        case .viewDidLayoutSubviews(let subview, let containerHeight):
            switch subview {
            case .filesGrid:
                filesGridViewDidLayoutSubviews(containerHeight)
            }
        case .viewSafeAreaInsetsDidChange:
            break
        }
    }
}

private extension LinkTagsCoordinator {
    func insertFilesGrid() {
        // Using root view controller as a presenter
        // for this specific coordinator, not currently started view controller
        
        let coordinator: FilesGridCoordinator = .init(vcFactory, presenterVC, navigationStack)
        coordinator.parent = self
        coordinator.start()
        filesGridCoordinator = coordinator
    }
    
    func viewDidLoad(_ bottomAnchor: NSLayoutYAxisAnchor?) {
        guard !isPad else {
            return
        }
        guard let tagsView = startedVC?.controllerView,
              let superView = presenterVC?.controllerView else {
            return
        }
        guard let bottomViewAnchor = bottomAnchor else {
            return
        }
        
        tagsView.leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
        tagsView.trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
        tagsView.heightAnchor.constraint(equalToConstant: .linkTagsHeight).isActive = true
        
        if isPad {
            let dummyViewHeight: CGFloat = .safeAreaBottomMargin
            let bottomMargin: CGFloat = dummyViewHeight + .linkTagsHeight
            hiddenTagsConstraint = tagsView.bottomAnchor.constraint(equalTo: bottomViewAnchor,
                                                                    constant: bottomMargin)
            showedTagsConstraint = tagsView.bottomAnchor.constraint(equalTo: bottomViewAnchor)
        } else {
            // If we want to show/hide the link tags view
            // we move it below bottom view on current view height
            hiddenTagsConstraint = tagsView.bottomAnchor.constraint(equalTo: bottomViewAnchor,
                                                                    constant: .linkTagsHeight)
            showedTagsConstraint = tagsView.bottomAnchor.constraint(equalTo: bottomViewAnchor)
        }
        hiddenTagsConstraint?.isActive = true
    }
    
    func filesGridViewDidLoad() {
        guard let bottomViewAnchor = startedVC?.controllerView.topAnchor else {
            return
        }
        filesGridCoordinator?.layout(.viewDidLoad(nil, bottomViewAnchor))
    }
    
    func filesGridViewDidLayoutSubviews(_ containerHeight: CGFloat?) {
        filesGridCoordinator?.layout(.viewDidLayoutSubviews(containerHeight))
    }
    
    func openTagsFor(instagram nodes: [InstagramVideoNode]) {
        tagsSiteDataSource = .instagram(nodes)
        linkTagsPresenter?.setLinks(nodes.count, for: .video)
        updateDownloadsViews()
    }

    func openTagsFor(html tags: [HTMLVideoTag]) {
        tagsSiteDataSource = .htmlVideos(tags)
        linkTagsPresenter?.setLinks(tags.count, for: .video)
        updateDownloadsViews()
    }

    func closeTags() {
        tagsSiteDataSource = nil
        filesGridCoordinator?.showNext(.hide)
        hideLinkTagsController()
        filesGridCoordinator?.showNext(.clear)
        linkTagsPresenter?.clearLinks()
    }
    
    func hideLinkTagsController() {
        guard isLinkTagsShowed else {
            return
        }
        isLinkTagsShowed = false
        self.showedTagsConstraint?.isActive = false
        self.hiddenTagsConstraint?.isActive = true
        UIView.animate(withDuration: 0.33) {
            self.startedVC?.controllerView.layoutIfNeeded()
        }
    }
    
    func updateDownloadsViews() {
        if isPad {
            mediaLinksPresenter?.didReceiveMediaLinks()
            guard let stack = navigationStack else {
                return
            }
            stack.modalPresentationStyle = .popover
            stack.preferredContentSize = CGSize(width: 300, height: .linkTagsHeight + 20)
            if let popoverPresenter = stack.popoverPresentationController,
               let popoverInfo = mediaLinksPresenter?.downloadsPopoverStartInfo {
                popoverPresenter.permittedArrowDirections = .any
                popoverPresenter.sourceRect = popoverInfo.1
                popoverPresenter.sourceView = popoverInfo.0
            }
            // Set correct presenter for Tablet layout now, because it is not
            // initialized at the time of creation/start
            presenterVC = vcFactory.createdDeviceSpecificSearchBarVC?.viewController
            presenterVC?.viewController.present(stack, animated: true, completion: nil)
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
        self.hiddenTagsConstraint?.isActive = false
        self.showedTagsConstraint?.isActive = true
        UIView.animate(withDuration: 0.33) {
            self.startedVC?.controllerView.layoutIfNeeded()
        }

    }
}

extension LinkTagsCoordinator: LinkTagsDelegate {
    func didSelect(type: LinksType, from sourceView: UIView) {
        guard let source = tagsSiteDataSource else {
            return
        }
        filesGridCoordinator?.showNext(.show(type, sourceView, sourceView.frame, source))
    }
}

extension LinkTagsCoordinator: DownloadPanelPresenter {
    func didPressDownloads(to hide: Bool) {
        if hide {
            filesGridCoordinator?.showNext(.hide)
            hideLinkTagsController()
        } else {
            // only can be used for phone layout
            // for table need to use `didPressTabletLayoutDownloads`
            updateDownloadsViews()
        }
    }
    
    func didPressTabletLayoutDownloads(from sourceView: UIView, and sourceRect: CGRect) {
        guard let source = tagsSiteDataSource else {
            return
        }
        
        if isPad {
            updateDownloadsViews()
        } else {
            // TODO: figure out if it is needed on Phone or this is not called at all
            filesGridCoordinator?.showNext(.show(.video, sourceView, sourceRect, source))
        }
    }
}

extension LinkTagsCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        guard let linkTagsVC = startedVC?.viewController else {
            return
        }
        if linkTagsVC == viewController {
            navigationStack?.preferredContentSize = CGSize(width: 300, height: .linkTagsHeight + 20)
        }
    }
}
