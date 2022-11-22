//
//  SearchBarCoordinator.swift
//  catowser
//
//  Created by Andrey Ermoshin on 22.11.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit

/// Need to inherit from NSobject to confirm to search bar delegate
final class SearchBarCoordinator: NSObject, Coordinator {
    let vcFactory: ViewControllerFactory
    var startedCoordinator: Coordinator?
    weak var parent: CoordinatorOwner?
    var startedVC: AnyViewController?
    weak var presenterVC: AnyViewController?
    
    private weak var downloadPanelDelegate: DonwloadPanelDelegate?
    private weak var globalMenuDelegate: GlobalMenuDelegate?
    
    init(_ vcFactory: ViewControllerFactory,
         _ presenter: AnyViewController,
         _ downloadPanelDelegate: DonwloadPanelDelegate,
         _ globalMenuDelegate: GlobalMenuDelegate) {
        self.vcFactory = vcFactory
        self.presenterVC = presenter
        self.downloadPanelDelegate = downloadPanelDelegate
        self.globalMenuDelegate = globalMenuDelegate
    }
    
    func start() {
        let createdVC: (any AnyViewController)?
        if isPad {
            createdVC = vcFactory.deviceSpecificSearchBarViewController(self, downloadPanelDelegate!, globalMenuDelegate!)
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

enum SearchBarRoute: Route {}

extension SearchBarCoordinator: Navigating {
    typealias R = SearchBarRoute
    
    func showNext(_ route: R) {}
    
    func stop() {
        startedVC?.viewController.removeFromChild()
        parent?.didFinish()
    }
}

extension SearchBarCoordinator: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty || searchText.looksLikeAURL() {
            hideSearchController()
        } else {
            showSearchControllerIfNeeded()
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
        // 400 IQ approach
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
