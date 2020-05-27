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

protocol MasterDelegate: class {
    var keyboardHeight: CGFloat? { get set }
    var toolbarHeight: CGFloat { get }
    var toolbarTopAnchor: NSLayoutYAxisAnchor { get }
    var popoverSourceView: UIView { get }

    func openSearchSuggestion(url: URL, suggestion: String)
    func openDomain(with url: URL)
}

protocol TagsRouterInterface: class {
    func openTagsFor(instagram nodes: [InstagramVideoNode])
    func openTagsFor(t4 video: T4Video)
    func openTagsFor(html tags: [HTMLVideoTag])
    func closeTags()
}

protocol SiteLifetimeInterface {
    func showProgress(_ show: Bool)
    func openTabMenu(from sourceView: UIView, and sourceRect: CGRect)
}

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

    private var isFilesGreedShowed: Bool = false

    fileprivate var dataSource: TagsSiteDataSource?

    private let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad ? true : false

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

    private weak var presenter: LinksRouterPresenter!
    
    /// Temporary property which automatically removes leading & trailing spaces.
    /// Can't declare it private due to compiler error.
    @LeadingTrimmed var tempSearchText: String = ""

    init(viewController: LinksRouterPresenter) {
        presenter = viewController
    }
}

extension MasterRouter: TagsRouterInterface {
    func openTagsFor(instagram nodes: [InstagramVideoNode]) {
        dataSource = .instagram(nodes)
        linkTagsController.setLinks(nodes.count, for: .video)
        showLinkTagsControllerIfNeeded()
    }
    
    func openTagsFor(t4 video: T4Video) {
        dataSource = .t4(video)
        linkTagsController.setLinks(1, for: .video)
        showLinkTagsControllerIfNeeded()
    }

    func openTagsFor(html tags: [HTMLVideoTag]) {
        dataSource = .htmlVideos(tags)
        linkTagsController.setLinks(tags.count, for: .video)
        showLinkTagsControllerIfNeeded()
    }

    func closeTags() {
        dataSource = nil
        hideFilesGreedIfNeeded()
        hideLinkTagsController()
        filesGreedController.clearFiles()
        linkTagsController.clearLinks()
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
    
    func openTabMenu(from sourceView: UIView, and sourceRect: CGRect) {
        showTabMenuIfNeeded(from: sourceView, and: sourceRect)
    }
}

fileprivate extension MasterRouter {
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

    func hideLinkTagsController() {
        guard isLinkTagsShowed else {
            return
        }
        showedTagsConstraint?.isActive = false
        hiddenTagsConstraint?.isActive = true

        linkTagsController.view.layoutIfNeeded()
        isLinkTagsShowed = false
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
    
    func showTabMenuIfNeeded(from sourceView: UIView, and sourceRect: CGRect) {
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
                let menuModel = SiteMenuModel { [weak self] in
                    self?.presenter
                        .viewController
                        .presentedViewController?
                        .dismiss(animated: true)
                }
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

    func startSearch(_ searchText: String) {
        searchSuggestionsController.prepareSearch(for: searchText)
    }
}

extension MasterRouter: LinkTagsDelegate {
    func didSelect(type: LinksType, from sourceView: UIView) {
        guard type == .video, let source = dataSource else {
            return
        }
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
                popoverPresenter.permittedArrowDirections = .down
                // no transforms, so frame can be used
                let sourceRect = sourceView.frame
                popoverPresenter.sourceRect = sourceRect
                popoverPresenter.sourceView = linkTagsController.view
            }
            filesGreedController.reloadWith(source: source, completion: nil)
            presenter.viewController.present(filesGreedController.viewController,
                                             animated: true,
                                             completion: nil)
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

extension MasterRouter: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty || searchText.looksLikeAURL() {
            hideSearchController()
        } else {
            showSearchControllerIfNeeded()
            // TODO: How to delay network request
            // https://stackoverflow.com/a/2471977/483101
            // or using Reactive api
            startSearch(searchText)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar,
                   shouldChangeTextIn range: NSRange,
                   replacementText text: String) -> Bool {
        guard let value = searchBar.text else {
            return text != " "
        }
        // UIKit's searchbar delegate uses modern String type
        // but at the same time legacy NSRange type
        // which can't be used in String API,
        // since it requires modern Range<String.Index>
        // https://exceptionshub.com/nsrange-to-rangestring-index.html
        let future = (value as NSString).replacingCharacters(in: range, with: text)
        // Only need to check that no leading spaces
        // trailing space is allowed to be able to construct
        // query requests with more than one word.
        tempSearchText = future
        return tempSearchText == future
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBarController.changeState(to: .startSearch, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearchController()
        searchBar.resignFirstResponder()
        searchBarController.changeState(to: .cancelTapped, animated: true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else {
            return
        }
        let content: SuggestionType
        if text.looksLikeAURL() {
            content = .looksLikeURL(text)
        } else {
            // need to open web view with url of search engine
            // and specific search queue
            content = .suggestion(text)
        }
        didSelect(content)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // called when `Cancel` pressed or search bar no more a first responder
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
