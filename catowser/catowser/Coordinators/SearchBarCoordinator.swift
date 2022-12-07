//
//  SearchBarCoordinator.swift
//  catowser
//
//  Created by Andrey Ermoshin on 22.11.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser
import FeaturesFlagsKit
import BrowserNetworking
import CoreHttpKit

protocol SearchBarDelegate: AnyObject {
    func openTab(_ content: Tab.ContentType)
    func layoutSuggestions()
}

/// Need to inherit from NSobject to confirm to search bar delegate
final class SearchBarCoordinator: NSObject, Coordinator {
    let vcFactory: ViewControllerFactory
    var startedCoordinator: Coordinator?
    weak var parent: CoordinatorOwner?
    var startedVC: AnyViewController?
    weak var presenterVC: AnyViewController?
    var navigationStack: UINavigationController?
    
    private weak var downloadPanelDelegate: DownloadPanelPresenter?
    private weak var globalMenuDelegate: GlobalMenuDelegate?
    private weak var delegate: SearchBarDelegate?
    
    private var searhSuggestionsCoordinator: SearchSuggestionsCoordinator?
    
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
    
    /// Temporary property which automatically removes leading spaces.
    /// Can't declare it private due to compiler error.
    @LeadingTrimmed private var tempSearchText: String = ""
    /// Tells if coordinator was already started
    private var isSuggestionsShowed: Bool = false
    
    init(_ vcFactory: ViewControllerFactory,
         _ presenter: AnyViewController,
         _ downloadPanelDelegate: DownloadPanelPresenter?,
         _ globalMenuDelegate: GlobalMenuDelegate?,
         _ delegate: SearchBarDelegate?) {
        self.vcFactory = vcFactory
        self.presenterVC = presenter
        self.downloadPanelDelegate = downloadPanelDelegate
        self.globalMenuDelegate = globalMenuDelegate
        self.delegate = delegate
    }
    
    func start() {
        let createdVC: (any AnyViewController)?
        if isPad {
            createdVC = vcFactory.deviceSpecificSearchBarViewController(self, downloadPanelDelegate, globalMenuDelegate)
        } else {
            createdVC = vcFactory.deviceSpecificSearchBarViewController(self)
        }
        guard let vc = createdVC, let controllerView = presenterVC?.controllerView else {
            return
        }
        
        vc.controllerView.translatesAutoresizingMaskIntoConstraints = false
        startedVC = vc
        presenterVC?.viewController.add(asChildViewController: vc.viewController, to: controllerView)
    }
}

enum SearchBarRoute: Route {
    case changeState(SearchBarState, Bool)
    case suggestions(String)
    case hideSuggestions
}

extension SearchBarCoordinator: Navigating {
    typealias R = SearchBarRoute
    
    func showNext(_ route: R) {
        switch route {
        case .changeState(let state, let animated):
            guard let searchInterface = startedVC as? SearchBarControllerInterface else {
                return
            }
            searchInterface.changeState(to: state, animated: animated)
        case .suggestions(let query):
            searhSuggestionsCoordinator?.showNext(.startSearch(query))
        case .hideSuggestions:
            hideSearchController()
        }
    }
    
    func stop() {
        startedVC?.viewController.removeFromChild()
    }
}

enum SearchBarPart: SubviewPart {
    case suggestions
}

extension SearchBarCoordinator: Layouting {
    typealias SP = SearchBarPart
    
    func insertNext(_ subview: SP) {
        switch subview {
        case .suggestions:
            insertSearchSuggestions()
        }
    }
    
    func layout(_ step: OwnLayoutStep) {
        switch step {
        case .viewDidLoad(let topAnchor, _, _):
            viewDidLoad(topAnchor)
        default:
            break
        }
    }
    
    func layoutNext(_ step: LayoutStep<SP>) {
        switch step {
        case .viewDidLoad(let subview, let topAnchor, let bottomAnchor, let toolbarHeight):
            switch subview {
            case .suggestions:
                searhSuggestionsCoordinator?.layout(.viewDidLoad(topAnchor, bottomAnchor, toolbarHeight))
            }
        default:
            break
        }
    }
}

extension SearchBarCoordinator: CoordinatorOwner {
    func coordinatorDidFinish(_ coordinator: Coordinator) {
        if coordinator === searhSuggestionsCoordinator {
            // maybe need to reuse it actually and not create it each time
            searhSuggestionsCoordinator = nil
        }
    }
}

private extension SearchBarCoordinator {
    func viewDidLoad(_ topAnchor: NSLayoutYAxisAnchor?) {
        guard let presenterView = presenterVC?.controllerView else {
            return
        }
        guard let searchView = startedVC?.controllerView else {
            return
        }
        if isPad, let topViewAnchor = topAnchor {
            searchView.topAnchor.constraint(equalTo: topViewAnchor).isActive = true
        } else {
            if #available(iOS 11, *) {
                searchView.topAnchor.constraint(equalTo: presenterView.safeAreaLayoutGuide.topAnchor).isActive = true
            } else {
                searchView.topAnchor.constraint(equalTo: presenterView.topAnchor).isActive = true
            }
        }
        searchView.leadingAnchor.constraint(equalTo: presenterView.leadingAnchor).isActive = true
        searchView.trailingAnchor.constraint(equalTo: presenterView.trailingAnchor).isActive = true
        searchView.heightAnchor.constraint(equalToConstant: .searchViewHeight).isActive = true
    }
    
    func insertSearchSuggestions() {
        guard !isSuggestionsShowed else {
            return
        }
        isSuggestionsShowed = true
        // Presenter for suggestions is root view controller
        
        // swiftlint:disable:next force_unwrapping
        let presenter = presenterVC!
        let coordinator: SearchSuggestionsCoordinator = .init(vcFactory, presenter, self)
        coordinator.parent = self
        coordinator.start()
        searhSuggestionsCoordinator = coordinator
    }
    
    func hideSearchController() {
        guard isSuggestionsShowed else {
            print("Attempted to hide suggestions when they are not showed")
            return
        }
        isSuggestionsShowed = false
        searhSuggestionsCoordinator?.stop()
    }
    
    func replaceTab(with url: URL, with suggestion: String? = nil) {
        let blockPopups = DefaultTabProvider.shared.blockPopups
        let isJSEnabled = FeatureManager.boolValue(of: .javaScriptEnabled)
        let settings = Site.Settings(isPrivate: false,
                                     blockPopups: blockPopups,
                                     isJSEnabled: isJSEnabled,
                                     canLoadPlugins: true)
        guard let site = Site(url, suggestion, settings) else {
            assertionFailure("\(#function) failed to replace current tab - failed create site")
            return
        }
        // tab content replacing will happen in `didCommit`
        delegate?.openTab(.site(site))
    }
}

extension SearchBarCoordinator: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty || searchText.looksLikeAURL() {
            showNext(.hideSuggestions)
        } else {
            insertNext(.suggestions)
            // Use delegate and not a direct call
            // because it requires layout info
            // about neighbour views (anchors and height)
            delegate?.layoutSuggestions()
            showNext(.suggestions(searchText))
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
        // 400 IQ approach
        return tempSearchText == future
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        showNext(.changeState(.startSearch, true))
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        showNext(.hideSuggestions)
        searchBar.resignFirstResponder()
        showNext(.changeState(.cancelTapped, true))
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

extension SearchBarCoordinator: SearchSuggestionsListDelegate {
    func didSelect(_ content: SuggestionType) {
        showNext(.hideSuggestions)

        switch content {
        case .looksLikeURL(let likeURL):
            guard let url = URL(string: likeURL) else {
                assertionFailure("Failed construct site URL using edited URL")
                return
            }
            replaceTab(with: url)
        case .knownDomain(let domain):
            guard let url = URL(string: "https://\(domain)") else {
                assertionFailure("Failed construct site URL using domain name")
                return
            }
            replaceTab(with: url)
        case .suggestion(let suggestion):
            guard let url = searchSuggestClient.searchURLForQuery(suggestion) else {
                assertionFailure("Failed construct search engine url from suggestion string")
                return
            }
            replaceTab(with: url, with: suggestion)
        }
    }
}

private extension FeatureManager {
    static func searchPluginName() -> KnownSearchPluginName {
        switch webSearchAutoCompleteValue() {
        case .google:
            return .google
        case .duckduckgo:
            return .duckduckgo
        }
    }
}
