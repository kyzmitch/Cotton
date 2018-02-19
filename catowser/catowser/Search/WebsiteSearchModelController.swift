//
//  WebsiteSearchModelController.swift
//  catowser
//
//  Created by Andrey Ermoshin on 10/10/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import UIKit

class WebsiteSearchModelController: NSObject {

    public lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
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

extension WebsiteSearchModelController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print("\(#function): search string or address: \(searchController.searchBar.text ?? "") ")
    }
}

extension WebsiteSearchModelController: UISearchBarDelegate {
    
}

extension WebsiteSearchModelController: UISearchControllerDelegate {
    
}
