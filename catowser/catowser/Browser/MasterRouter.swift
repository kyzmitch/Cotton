//
//  MasterRouter.swift
//  catowser
//
//  Created by Andrei Ermoshin on 03/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import HttpKit
import CoreBrowser
import JSPlugins
import ReactiveSwift

protocol MasterDelegate: class {
    var keyboardHeight: CGFloat? { get set }
    var toolbarHeight: CGFloat { get }
    var toolbarTopAnchor: NSLayoutYAxisAnchor { get }
    var popoverSourceView: UIView { get }

    func openSearchSuggestion(url: URL, suggestion: String)
    func openDomain(with url: URL)
}

protocol LinksRouterInterface: class {
    func openTagsFor(instagram nodes: [InstagramVideoNode])
    func openTagsFor(t4 video: T4Video)
    func openTagsFor(html tags: [HTMLVideoTag])
    func closeTags()
    func showProgress(_ show: Bool)
}

/// Should contain copies for references to all needed constraints and view controllers. NSObject subclass to support system delegate protocol.
final class MasterRouter: NSObject {
    /// The table to display search suggestions list
    let searchSuggestionsController: SearchSuggestionsViewController = {
        let vc = SearchSuggestionsViewController()
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
    
    private var searchSuggestionsDisposable: Disposable?
    
    private lazy var googleClient: HttpKit.Client<HttpKit.GoogleServer> = {
        let description = HttpKit.GoogleServer()
        return HttpKit.Client(server: description)
    }()

    private let searchSuggestClient: SearchSuggestClient = {
        guard let currentEngine = try? HttpKit.SearchEngine("", engineID: "") else {
            return SearchSuggestClient(.googleSearchEngine())
        }
        let client = SearchSuggestClient(currentEngine)
        return client
    }()

    typealias LinksRouterPresenter = AnyViewController & MasterDelegate

    private weak var presenter: LinksRouterPresenter!

    init(viewController: LinksRouterPresenter) {
        presenter = viewController
    }

    deinit {
        searchSuggestionsDisposable?.dispose()
    }
}

extension MasterRouter: LinksRouterInterface {
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

fileprivate extension MasterRouter {
    func showFilesGreedIfNeeded() {
        guard !isFilesGreedShowed else {
            return
        }

        if !isPad {
            hiddenFilesGreedConstraint?.isActive = false
            showedFilesGreedConstraint?.isActive = true

            UIView.animate(withDuration: 0.6) {
                self.filesGreedController.view.layoutIfNeeded()
            }
        } else {

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

        searchSuggestionsController.view.topAnchor.constraint(equalTo: searchBarController.view.bottomAnchor, constant: 0).isActive = true
        searchSuggestionsController.view.leadingAnchor.constraint(equalTo: presenter.view.leadingAnchor, constant: 0).isActive = true
        searchSuggestionsController.view.trailingAnchor.constraint(equalTo: presenter.view.trailingAnchor, constant: 0).isActive = true

        if let bottomShift = presenter.keyboardHeight {
            // fix wrong height of keyboard on Simulator when keyboard partly visible
            let correctedShift = bottomShift < presenter.toolbarHeight ? presenter.toolbarHeight : bottomShift
            searchSuggestionsController.view.bottomAnchor.constraint(equalTo: presenter.view.bottomAnchor, constant: -correctedShift).isActive = true
        } else {
            if isPad {
                searchSuggestionsController.view.bottomAnchor.constraint(equalTo: presenter.toolbarTopAnchor, constant: 0).isActive = true
            } else {
                searchSuggestionsController.view.bottomAnchor.constraint(equalTo: presenter.view.bottomAnchor, constant: 0).isActive = true
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

    func startSearch(_ searchText: String) {
        searchSuggestionsController.suggestions.removeAll()
        searchSuggestionsController.knownDomains.removeAll()

        searchSuggestionsController.knownDomains = InMemoryDomainSearchProvider.shared.domainNames(whereURLContains: searchText)

        searchSuggestionsDisposable?.dispose()
        searchSuggestionsDisposable = googleClient.searchSuggestions(for: searchText)
            .observe(on: QueueScheduler.main)
            .startWithResult { [weak self] (result) in
                switch result {
                case .success(let response):
                    self?.searchSuggestionsController.suggestions = response.textResults
                case .failure(let error):
                    print("Fail to fetch search suggestions \(error.localizedDescription)")
                }
        }
    }
}

extension MasterRouter: LinkTagsDelegate {
    func didSelect(type: LinksType) {
        if type == .video, let source = dataSource {
            if isFilesGreedShowed {
                hideFilesGreedIfNeeded()
            } else {
                if !isPad {
                    filesGreedController.reloadWith(source: source) { [weak self] in
                        self?.showFilesGreedIfNeeded()
                    }
                } else {
                    filesGreedController.viewController.modalPresentationStyle = .popover
                    filesGreedController.viewController.preferredContentSize = CGSize(width: 500, height: 600)
                    if let popoverPresenter = filesGreedController.viewController.popoverPresentationController {
                        popoverPresenter.permittedArrowDirections = .down
                        popoverPresenter.sourceView = linkTagsController.view
                    }
                    filesGreedController.reloadWith(source: source, completion: nil)
                    presenter.viewController.present(filesGreedController.viewController, animated: true, completion: nil)
                }
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
            guard let url = searchSuggestClient.searchURL(basedOn: suggestion) else {
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
