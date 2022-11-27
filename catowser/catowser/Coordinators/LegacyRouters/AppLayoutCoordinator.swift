//
//  AppLayoutCoordinator.swift
//  catowser
//
//  Created by Andrei Ermoshin on 03/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser
import JSPlugins
import CoreHttpKit
import BrowserNetworking
import FeaturesFlagsKit
#if canImport(SwiftUI)
import SwiftUI
#endif

protocol MediaLinksPresenter: AnyObject {
    func didReceiveMediaLinks()
}

/// Should contain copies for references to all needed constraints and view controllers.
/// NSObject subclass to support system delegate protocol.
final class AppLayoutCoordinator: NSObject {

    /// The link tags controller to display segments with link types amount
    lazy var linkTagsController: AnyViewController & LinkTagsPresenter = {
        let vc = LinkTagsViewController.newFromStoryboard(delegate: self)
        return vc
    }()

    /// The files greed controller to display links for downloads
    lazy var filesGreedController: AnyViewController & FilesGreedPresenter = {
        let vc = FilesGreedViewController.newFromStoryboard()
        return vc
    }()
    
    private weak var mediaLinksPresenter: MediaLinksPresenter?

    // MARK: All constraints should be stored by strong references because they are removed during deactivation

    var hiddenTagsConstraint: NSLayoutConstraint?

    var showedTagsConstraint: NSLayoutConstraint?

    var hiddenFilesGreedConstraint: NSLayoutConstraint?

    var showedFilesGreedConstraint: NSLayoutConstraint?

    var filesGreedHeightConstraint: NSLayoutConstraint?

    var underLinksViewHeightConstraint: NSLayoutConstraint?

    private var isLinkTagsShowed: Bool = false

    private(set) var isFilesGreedShowed: Bool = false

    var tagsSiteDataSource: TagsSiteDataSource?

    let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad

    private(set) weak var presenter: (AnyViewController & GlobalMenuDelegate)!

    init(viewController: AnyViewController & GlobalMenuDelegate) {
        presenter = viewController
    }
    
    // MARK: - originally private methods
    
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
            self.linkTagsController.controllerView.layoutIfNeeded()
        }
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

        linkTagsController.controllerView.layoutIfNeeded()
        isLinkTagsShowed = false
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
    
    func presentVideoViews(using source: TagsSiteDataSource,
                           from sourceView: UIView,
                           and sourceRect: CGRect) {
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
        linkTagsController.setLinks(nodes.count, for: .video)
        updateDownloadsViews()
    }

    func openTagsFor(html tags: [HTMLVideoTag]) {
        tagsSiteDataSource = .htmlVideos(tags)
        linkTagsController.setLinks(tags.count, for: .video)
        updateDownloadsViews()
    }

    func closeTags() {
        tagsSiteDataSource = nil
        hideFilesGreedIfNeeded()
        hideLinkTagsController()
        filesGreedController.clearFiles()
        linkTagsController.clearLinks()
    }
}

extension AppLayoutCoordinator: DonwloadPanelDelegate {
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

extension FeatureManager {
    static func searchPluginName() -> KnownSearchPluginName {
        switch webSearchAutoCompleteValue() {
        case .google:
            return .google
        case .duckduckgo:
            return .duckduckgo
        }
    }
}
