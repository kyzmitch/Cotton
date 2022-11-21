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

typealias LinksRouterPresenter = AnyViewController & MainDelegate & GlobalMenuDelegate

/// Should contain copies for references to all needed constraints and view controllers.
/// NSObject subclass to support system delegate protocol.
final class AppLayoutCoordinator: NSObject {
    /// The table to display search suggestions list
    func createSuggestionsController() -> SearchSuggestionsViewController {
        // It seems it should be computed property
        // to allow app. to use different view model
        // based on current feature flag's value
        return SearchSuggestionsViewController()
    }
    
    var searchSuggestionsVC: SearchSuggestionsViewController?

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

    lazy var searchBarController: AnyViewController & SearchBarControllerInterface = {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let tabletController = TabletSearchBarViewController(self, presenter, self)
            mediaLinksPresenter = tabletController
            return tabletController
        } else {
            return SmartphoneSearchBarViewController(self)
        }
    }()
    
    private weak var mediaLinksPresenter: MediaLinksPresenter?

    // MARK: All constraints should be stored by strong references because they are removed during deactivation

    var hiddenTagsConstraint: NSLayoutConstraint?

    var showedTagsConstraint: NSLayoutConstraint?
    
    var hiddenWebLoadConstraint: NSLayoutConstraint?
    
    var showedWebLoadConstraint: NSLayoutConstraint?

    var hiddenFilesGreedConstraint: NSLayoutConstraint?

    var showedFilesGreedConstraint: NSLayoutConstraint?

    var filesGreedHeightConstraint: NSLayoutConstraint?

    var underLinksViewHeightConstraint: NSLayoutConstraint?

    private var isSuggestionsShowed: Bool = false

    private var isLinkTagsShowed: Bool = false

    private(set) var isFilesGreedShowed: Bool = false

    var tagsSiteDataSource: TagsSiteDataSource?

    let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad

    private var searchSuggestClient: SearchEngine {
        let optionalXmlData = ResourceReader.readXmlSearchPlugin(with: FeatureManager.searchPluginName(), on: .main)
        guard let xmlData = optionalXmlData else {
            return .googleSearchEngine()
        }
        
        let osDescription: OpenSearch.Description
        do {
            osDescription = try OpenSearch.Description(data: xmlData)
        } catch {
            print("Open search xml parser error: \(error.localizedDescription)")
            return .googleSearchEngine()
        }
        
        return osDescription.html
    }

    private(set) weak var presenter: LinksRouterPresenter!
    
    /// Temporary property which automatically removes leading spaces.
    /// Can't declare it private due to compiler error.
    @LeadingTrimmed var tempSearchText: String = ""

    init(viewController: LinksRouterPresenter) {
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
    
    func hideSearchController() {
        guard isSuggestionsShowed else {
            print("Attempted to hide suggestions when they are not showed")
            return
        }
        
        guard let searchSuggestionsController = searchSuggestionsVC else { return }

        searchSuggestionsController.willMove(toParent: nil)
        searchSuggestionsController.removeFromParent()
        // remove view and constraints
        searchSuggestionsController.view.removeFromSuperview()

        isSuggestionsShowed = false
    }
    
    func showSearchControllerIfNeeded() {
        guard !isSuggestionsShowed else {
            return
        }
        
        searchSuggestionsVC = createSuggestionsController()
        guard let searchSuggestionsController = searchSuggestionsVC else { return }

        presenter.viewController.add(asChildViewController: searchSuggestionsController, to: presenter.controllerView)
        isSuggestionsShowed = true
        searchSuggestionsController.delegate = self

        searchSuggestionsController.view.topAnchor.constraint(equalTo: searchBarController.controllerView.bottomAnchor,
                                                              constant: 0).isActive = true
        searchSuggestionsController.view.leadingAnchor.constraint(equalTo: presenter.controllerView.leadingAnchor,
                                                                  constant: 0).isActive = true
        searchSuggestionsController.view.trailingAnchor.constraint(equalTo: presenter.controllerView.trailingAnchor,
                                                                   constant: 0).isActive = true

        if let bottomShift = presenter.keyboardHeight {
            // fix wrong height of keyboard on Simulator when keyboard partly visible
            let correctedShift = bottomShift < presenter.toolbarHeight ? presenter.toolbarHeight : bottomShift
            searchSuggestionsController.view.bottomAnchor.constraint(equalTo: presenter.controllerView.bottomAnchor,
                                                                     constant: -correctedShift).isActive = true
        } else {
            if isPad {
                searchSuggestionsController.view.bottomAnchor.constraint(equalTo: presenter.toolbarTopAnchor,
                                                                         constant: 0).isActive = true
            } else {
                searchSuggestionsController.view.bottomAnchor.constraint(equalTo: presenter.controllerView.bottomAnchor,
                                                                         constant: 0).isActive = true
            }
        }
    }
    
    func startSearch(_ searchText: String) {
        searchSuggestionsVC?.prepareSearch(for: searchText)
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
    
    func showProgress(_ show: Bool) {
        if show {
            hiddenWebLoadConstraint?.isActive = false
            showedWebLoadConstraint?.isActive = true
        } else {
            showedWebLoadConstraint?.isActive = false
            hiddenWebLoadConstraint?.isActive = true
        }
    }
}

extension AppLayoutCoordinator: SearchSuggestionsListDelegate {
    func didSelect(_ content: SuggestionType) {
        hideSearchController()

        switch content {
        case .looksLikeURL(let likeURL):
            guard let url = URL(string: likeURL) else {
                assertionFailure("Failed construct site URL using edited URL")
                return
            }
            presenter.openDomain(with: url)
        case .knownDomain(let domain):
            guard let url = URL(string: "https://\(domain)") else {
                assertionFailure("Failed construct site URL using domain name")
                return
            }
            presenter.openDomain(with: url)
        case .suggestion(let suggestion):
            guard let url = searchSuggestClient.searchURLForQuery(suggestion) else {
                assertionFailure("Failed construct search engine url from suggestion string")
                return
            }
            presenter.openSearchSuggestion(url: url, suggestion: suggestion)
        }
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
