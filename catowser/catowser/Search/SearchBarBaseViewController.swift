//
//  SearchBarBaseViewController.swift
//  catowser
//
//  Created by admin on 19/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//

import UIKit

class SearchBarBaseViewController: BaseViewController {

    private var searchBarContainerView: UISearchBar?
    private let websiteAddressSearchController = WebsiteSearchControllerHolder(nil /* TODO: pass view controller instead of nil */)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addSearchBar(from: websiteAddressSearchController.searchController)
        
        searchBarContainerView?.snp.makeConstraints { (maker) in
            maker.top.equalTo(0)
            maker.leading.equalTo(0)
            maker.trailing.equalTo(0)
            maker.bottom.equalTo(0)
        }
    }

    private func addSearchBar(from searchController: UISearchController) {
        // ensure that the search bar does not remain on the screen
        // if the user navigates to another view controller
        // while the UISearchController is active.
        definesPresentationContext = true
        // NOTE: you should never push to navigation controller or use it as a child etc.
        // If you want that, you can use UISearchContainerViewController to wrap it first.
        // http://samwize.com/2016/11/27/uisearchcontroller-development-guide/
        let container = UISearchContainerViewController(searchController: searchController)
        addChildViewController(container)
        searchBarContainerView = searchController.searchBar
        view.addSubview(searchController.searchBar)
        container.didMove(toParentViewController: self)
    }
}
