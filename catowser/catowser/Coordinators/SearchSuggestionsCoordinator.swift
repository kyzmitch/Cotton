//
//  SearchSuggestionsCoordinator.swift
//  catowser
//
//  Created by Andrei Ermoshin on 11/14/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit

enum SearchSuggestionsRoute: Route {}

final class SearchSuggestionsCoordinator: Coordinator, Navigating {
    typealias R = SearchSuggestionsRoute
    
    let vcFactory: ViewControllerFactory
    var startedCoordinator: Coordinator?
    weak var parent: CoordinatorOwner?
    
    private let searchBarDelegate: UISearchBarDelegate
    
    init(_ vcFactory: ViewControllerFactory,
         _ searchBarDelegate: UISearchBarDelegate) {
        self.vcFactory = vcFactory
        self.searchBarDelegate = searchBarDelegate
    }
    
    func start() {
        
    }
    
    func showNext(_ route: SearchSuggestionsRoute) {
        
    }
}

extension SearchSuggestionsCoordinator: CoordinatorOwner {
    func didFinish() {
        startedCoordinator = nil
    }
}
