//
//  LinkTagsCoordinator.swift
//  catowser
//
//  Created by Andrei Ermoshin on 11/28/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit
import JSPlugins

protocol MediaLinksPresenter: AnyObject {
    func didReceiveMediaLinks()
}

final class LinkTagsCoordinator: Coordinator {
    let vcFactory: any ViewControllerFactory
    var startedCoordinator: Coordinator?
    weak var parent: CoordinatorOwner?
    var startedVC: AnyViewController?
    weak var presenterVC: AnyViewController?
    
    // MARK: - state properties
    
    /// Specific coordinator type
    private var filesGridCoordinator: FilesGridCoordinator?
    private var isLinkTagsShowed: Bool = false
    
    private var tagsSiteDataSource: TagsSiteDataSource?
    private weak var viewInterface: LinkTagsPresenter?
    private weak var mediaLinksPresenter: MediaLinksPresenter?
    
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
        filesGridCoordinator = nil
        // TODO: maybe need to call `parent?.didFinish()`
    }
}

extension LinkTagsCoordinator: CoordinatorOwner {}

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
        case .viewDidLoad(let topAnchor, let bottomAnchor):
            viewDidLoad(topAnchor, bottomAnchor)
        case .viewDidLayoutSubviews:
            break
        case .viewSafeAreaInsetsDidChange:
            break
        }
    }
    
    func layoutNext(_ step: LayoutStep<SP>) {
        switch step {
        case .viewDidLoad(let subview):
            switch subview {
            case .filesGrid:
                filesGridViewDidLoad()
            default:
                break
            }
        case .viewDidLayoutSubviews(let subview, let containerHeight):
            switch subview {
            case .filesGrid:
                guard let height = containerHeight else {
                    return
                }
                filesGridViewDidLayoutSubviews(height)
            default:
                break
            }
        case .viewSafeAreaInsetsDidChange(let subview):
            break
        }
    }
}

private extension LinkTagsCoordinator {
    func insertFilesGrid() {
        // Using root view controller as a presenter
        // for this specific coordinator, not currently started view controller
        
        // swiftlint:disable:next force_unwrapping
        let presenter = presenterVC!
        let coordinator: FilesGridCoordinator = .init(vcFactory, presenter)
        coordinator.parent = self
        coordinator.start()
        filesGridCoordinator = coordinator
    }
    
    func viewDidLoad(_ topAnchor: NSLayoutYAxisAnchor?, _ bottomAnchor: NSLayoutYAxisAnchor?) {
        guard let tagsView = startedVC?.controllerView, let containerView = presenterVC?.controllerView else {
            return
        }
        if isPad {
            guard let bottomAnchor = bottomAnchor, let topAnchor = topAnchor else {
                return
            }
            let dummyViewHeight: CGFloat = .safeAreaBottomMargin
            let bottomMargin: CGFloat = dummyViewHeight + .linkTagsHeight
            hiddenTagsConstraint = bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: bottomMargin)
            showedTagsConstraint = bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            
            let tagsBottom = tagsView.bottomAnchor
            tagsBottom.constraint(equalTo: topAnchor).isActive = true
        } else {
            guard let topAnchor = topAnchor else {
                return
            }
            hiddenTagsConstraint = tagsView.bottomAnchor.constraint(equalTo: topAnchor, constant: .linkTagsHeight)
            showedTagsConstraint = tagsView.bottomAnchor.constraint(equalTo: topAnchor)
        }
        hiddenTagsConstraint?.isActive = true
        
        tagsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        tagsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        tagsView.heightAnchor.constraint(equalToConstant: .linkTagsHeight).isActive = true
    }
    
    func filesGridViewDidLoad() {
        guard let anchor = startedVC?.controllerView.topAnchor else {
            return
        }
        filesGridCoordinator?.layout(.viewDidLoad(nil, anchor))
    }
    
    func filesGridViewDidLayoutSubviews(_ containerHeight: CGFloat) {
        filesGridCoordinator?.layout(.viewDidLayoutSubviews(containerHeight))
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
        filesGridCoordinator?.showNext(.hide)
        hideLinkTagsController()
        filesGridCoordinator?.showNext(.clear)
        viewInterface?.clearLinks()
    }
    
    func hideLinkTagsController() {
        guard isLinkTagsShowed else {
            return
        }
        showedTagsConstraint?.isActive = false
        hiddenTagsConstraint?.isActive = true

        startedVC?.controllerView.layoutIfNeeded()
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
            self.startedVC?.controllerView.layoutIfNeeded()
        }
    }
}

extension LinkTagsCoordinator: LinkTagsDelegate {
    func didSelect(type: LinksType, from sourceView: UIView) {
        guard let source = tagsSiteDataSource else {
            return
        }
        filesGridCoordinator?.showNext(.videos(type, sourceView, sourceView.frame, source))
    }
}

extension LinkTagsCoordinator: DonwloadPanelDelegate {
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
        filesGridCoordinator?.showNext(.videos(.video, sourceView, sourceRect, source))
    }
}
