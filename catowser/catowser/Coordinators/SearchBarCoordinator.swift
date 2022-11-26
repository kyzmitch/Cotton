//
//  SearchBarCoordinator.swift
//  catowser
//
//  Created by Andrey Ermoshin on 22.11.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser

protocol SearchBarDelegate: AnyObject {
    var toolbarHeight: CGFloat { get }
    var toolbarTopAnchor: NSLayoutYAxisAnchor { get }
}

/// Need to inherit from NSobject to confirm to search bar delegate
final class SearchBarCoordinator: NSObject, Coordinator {
    let vcFactory: ViewControllerFactory
    var startedCoordinator: Coordinator?
    weak var parent: CoordinatorOwner?
    var startedVC: AnyViewController?
    weak var presenterVC: AnyViewController?
    
    private weak var downloadPanelDelegate: DonwloadPanelDelegate?
    private weak var globalMenuDelegate: GlobalMenuDelegate?
    private weak var delegate: SearchBarDelegate?
    
    private var searhSuggestionsCoordinator: (any Navigating)?
    
    /// Temporary property which automatically removes leading spaces.
    /// Can't declare it private due to compiler error.
    @LeadingTrimmed private var tempSearchText: String = ""
    /// Tells if coordinator was already started
    private var isSuggestionsShowed: Bool = false
    
    init(_ vcFactory: ViewControllerFactory,
         _ presenter: AnyViewController,
         _ downloadPanelDelegate: DonwloadPanelDelegate,
         _ globalMenuDelegate: GlobalMenuDelegate,
         _ delegate: SearchBarDelegate) {
        self.vcFactory = vcFactory
        self.presenterVC = presenter
        self.downloadPanelDelegate = downloadPanelDelegate
        self.globalMenuDelegate = globalMenuDelegate
        self.delegate = delegate
    }
    
    func start() {
        let createdVC: (any AnyViewController)?
        if isPad {
            // swiftlint:disable:next force_unwrapping
            let downloadDelegate = downloadPanelDelegate!
            // swiftlint:disable:next force_unwrapping
            let menuDelegate = globalMenuDelegate!
            createdVC = vcFactory.deviceSpecificSearchBarViewController(self, downloadDelegate, menuDelegate)
        } else {
            createdVC = vcFactory.deviceSpecificSearchBarViewController(self)
        }
        guard let vc = createdVC, let contentContainerView = presenterVC?.controllerView else {
            return
        }
        
        startedVC = vc
        presenterVC?.viewController.add(asChildViewController: vc.viewController, to: contentContainerView)
    }
}

enum SearchBarRoute: Route {
    case changeState(SearchBarState, Bool)
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
        }
    }
    
    func stop() {
        startedVC?.viewController.removeFromChild()
        parent?.didFinish()
    }
}

enum SearchBarPart: SubviewPart {
    case suggestions(String)
}

extension SearchBarCoordinator: SubviewNavigation {
    typealias SP = SearchBarPart
    
    func insertNext(_ subview: SP) {
        switch subview {
        case .suggestions(let query):
            insertSearchSuggestions(query)
        }
    }
}

extension SearchBarCoordinator: CoordinatorOwner {
    func didFinish() {
        startedCoordinator = nil
    }
}

private extension SearchBarCoordinator {
    func insertSearchSuggestions(_ searchText: String) {
        guard !isSuggestionsShowed,
        let toolbarHeight = delegate?.toolbarHeight,
        let toolbarTopAnchor = delegate?.toolbarTopAnchor else {
            return
        }
        
        // swiftlint:disable:next force_unwrapping
        let presenter = startedVC!
        let coordinator: SearchSuggestionsCoordinator = .init(vcFactory,
                                                              presenter,
                                                              presenter.controllerView.bottomAnchor,
                                                              toolbarTopAnchor,
                                                              toolbarHeight)
        coordinator.parent = self
        coordinator.start()
        isSuggestionsShowed = true
        searhSuggestionsCoordinator = coordinator
    }
    
    func hideSearchController() {
        guard isSuggestionsShowed else {
            print("Attempted to hide suggestions when they are not showed")
            return
        }
        
        searhSuggestionsCoordinator?.stop()
        isSuggestionsShowed = false
    }
}

extension SearchBarCoordinator: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty || searchText.looksLikeAURL() {
            hideSearchController()
        } else {
            insertNext(.suggestions(searchText))
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
        hideSearchController()
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
