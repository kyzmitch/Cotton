//
//  WebsiteSearchControllerHolder.swift
//  catowser
//
//  Created by Andrey Ermoshin on 10/10/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import UIKit

class WebsiteSearchControllerHolder: NSObject {

    private let resultsController: UIViewController?
    
    init(_ searchResultsController: UIViewController?) {
        resultsController = searchResultsController
    }
    
    public lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: resultsController)
        controller.searchResultsUpdater = self
        controller.delegate = self
        controller.searchBar.delegate = self
        // not dim master view, because searchResultsController is not used
        // probably need to try to set searchResultsController to show
        // search results in it
        controller.dimsBackgroundDuringPresentation = false
        return controller
    }()
}

extension WebsiteSearchControllerHolder: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        print("\(#function): search string or address: \(text)")
    }
}

extension WebsiteSearchControllerHolder: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("\(#function): pressed")
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("\(#function):")
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("\(#function):")
    }
}

extension WebsiteSearchControllerHolder: UISearchControllerDelegate {
    
}
