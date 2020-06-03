//
//  MasterRouter.swift
//  catowser
//
//  Created by Andrei Ermoshin on 03/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser
import JSPlugins
import HttpKit
#if canImport(SwiftUI)
import SwiftUI
#endif

/// Should contain copies for references to all needed constraints and view controllers.
/// NSObject subclass to support system delegate protocol.
final class MasterRouter: NSObject {
    /// The table to display search suggestions list
    let searchSuggestionsController: SearchSuggestionsViewController = {
        let vc = SearchSuggestionsViewController(GoogleSuggestionsClient.shared)
        return vc
    }()

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
            return TabletSearchBarViewController(self)
        } else {
            return SmartphoneSearchBarViewController(self)
        }
    }()

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

    var dataSource: TagsSiteDataSource?

    let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad ? true : false

    private let searchSuggestClient: HttpKit.SearchEngine = {
        let optionalXmlData = ResourceReader.readXmlSearchPlugin(with: .duckduckgo, on: .main)
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
    }()

    typealias LinksRouterPresenter = AnyViewController & MasterDelegate

    private(set) weak var presenter: LinksRouterPresenter!
    /// Need to update this navigation delegate each time it changes in router holder
    weak var siteNavigationDelegate: SiteNavigationDelegate?
    
    /// Temporary property which automatically removes leading spaces.
    /// Can't declare it private due to compiler error.
    @LeadingTrimmed var tempSearchText: String = ""

    init(viewController: LinksRouterPresenter) {
        presenter = viewController
    }
    
    // MARK: - originally private methods
    
    func showLinkTagsControllerIfNeeded() {
        guard !isLinkTagsShowed else {
            return
        }

        isLinkTagsShowed = true
        // Order of disabling/enabling is important to not to cause errors in layout calculation.
        hiddenTagsConstraint?.isActive = false
        showedTagsConstraint?.isActive = true

        UIView.animate(withDuration: 0.33) {
            self.linkTagsController.view.layoutIfNeeded()
        }
    }
    
    func hideFilesGreedIfNeeded() {
        guard isFilesGreedShowed else {
            return
        }

        if !isPad {
            showedFilesGreedConstraint?.isActive = false
            hiddenFilesGreedConstraint?.isActive = true

            filesGreedController.view.layoutIfNeeded()
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

        linkTagsController.view.layoutIfNeeded()
        isLinkTagsShowed = false
    }
    
    func hideSearchController() {
        guard isSuggestionsShowed else {
            print("Attempted to hide suggestions when they are not showed")
            return
        }

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

        presenter.viewController.add(asChildViewController: searchSuggestionsController, to: presenter.view)
        isSuggestionsShowed = true
        searchSuggestionsController.delegate = self

        searchSuggestionsController.view.topAnchor.constraint(equalTo: searchBarController.view.bottomAnchor,
                                                              constant: 0).isActive = true
        searchSuggestionsController.view.leadingAnchor.constraint(equalTo: presenter.view.leadingAnchor,
                                                                  constant: 0).isActive = true
        searchSuggestionsController.view.trailingAnchor.constraint(equalTo: presenter.view.trailingAnchor,
                                                                   constant: 0).isActive = true

        if let bottomShift = presenter.keyboardHeight {
            // fix wrong height of keyboard on Simulator when keyboard partly visible
            let correctedShift = bottomShift < presenter.toolbarHeight ? presenter.toolbarHeight : bottomShift
            searchSuggestionsController.view.bottomAnchor.constraint(equalTo: presenter.view.bottomAnchor,
                                                                     constant: -correctedShift).isActive = true
        } else {
            if isPad {
                searchSuggestionsController.view.bottomAnchor.constraint(equalTo: presenter.toolbarTopAnchor,
                                                                         constant: 0).isActive = true
            } else {
                searchSuggestionsController.view.bottomAnchor.constraint(equalTo: presenter.view.bottomAnchor,
                                                                         constant: 0).isActive = true
            }
        }
    }
    
    func startSearch(_ searchText: String) {
        searchSuggestionsController.prepareSearch(for: searchText)
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
            self.filesGreedController.view.layoutIfNeeded()
        }

        isFilesGreedShowed = true
    }
}

extension MasterRouter: SiteLifetimeInterface {
    func showProgress(_ show: Bool) {
        if show {
            hiddenWebLoadConstraint?.isActive = false
            showedWebLoadConstraint?.isActive = true
        } else {
            showedWebLoadConstraint?.isActive = false
            hiddenWebLoadConstraint?.isActive = true
        }
    }
    
    func openTabMenu(from sourceView: UIView,
                     and sourceRect: CGRect,
                     for host: HttpKit.Host,
                     siteSettings: Site.Settings) {
        showTabMenuIfNeeded(from: sourceView,
                            and: sourceRect,
                            for: host,
                            siteSettings: siteSettings)
    }
}

fileprivate extension MasterRouter {
    func showTabMenuIfNeeded(from sourceView: UIView,
                             and sourceRect: CGRect,
                             for host: HttpKit.Host,
                             siteSettings: Site.Settings) {
        let isDoHEnabled = FeatureManager.boolValue(of: .dnsOverHTTPSAvailable)
        let dnsMsg = NSLocalizedString("txt_doh_menu_item", comment: "Title of DoH menu item")
        let msg = "\(dnsMsg) \(isDoHEnabled ? "enabled" : "disabled")"
        let alert: UIAlertController = .init(title: nil,
                                             message: msg,
                                             preferredStyle: .actionSheet)
        let eAction = UIAlertAction(title: "Enable", style: .default) { (_) in
            FeatureManager.setFeature(.dnsOverHTTPSAvailable, value: true)
        }
        let dAction = UIAlertAction(title: "Disable", style: .default) { (_) in
            FeatureManager.setFeature(.dnsOverHTTPSAvailable, value: false)
        }
        alert.addAction(eAction)
        alert.addAction(dAction)

        if isPad {
            if let popoverPresenter = alert.popoverPresentationController {
                // for iPad
                popoverPresenter.sourceView = sourceView
                popoverPresenter.sourceRect = sourceRect
            }
            presenter.viewController.present(alert,
                                             animated: true)
        } else {
            if #available(iOS 13.0, *) {
                let popClosure: DismissClosure = { [weak self] in
                    self?.presenter
                        .viewController
                        .presentedViewController?
                        .dismiss(animated: true)
                }
                let menuModel = SiteMenuModel(host: host,
                                              settings: siteSettings,
                                              siteDelegate: siteNavigationDelegate,
                                              dismiss: popClosure)
                let menuHostVC = SiteMenuViewController(model: menuModel)
                presenter.viewController.present(menuHostVC,
                                                 animated: true)
            } else {
                // FIXME: this causes layout error for some reason
                presenter.viewController.present(alert,
                                                 animated: true)
            }
        }
    }
}

extension MasterRouter: SearchSuggestionsListDelegate {
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

extension MasterRouter: DonwloadPanelDelegate {
    func didPressDownloads(to hide: Bool) {
        if hide {
            hideFilesGreedIfNeeded()
            hideLinkTagsController()
        } else {
            showLinkTagsControllerIfNeeded()
        }
    }
}
