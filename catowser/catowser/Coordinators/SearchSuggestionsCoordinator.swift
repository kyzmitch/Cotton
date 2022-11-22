//
//  SearchSuggestionsCoordinator.swift
//  catowser
//
//  Created by Andrei Ermoshin on 11/14/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit

final class SearchSuggestionsCoordinator: Coordinator {
    let vcFactory: any ViewControllerFactory
    var startedCoordinator: Coordinator?
    weak var parent: CoordinatorOwner?
    var startedVC: AnyViewController?
    var presenterVC: AnyViewController?
    
    init(_ vcFactory: any ViewControllerFactory) {
        self.vcFactory = vcFactory
    }
    
    func start() {
        
    }
}

extension SearchSuggestionsCoordinator: CoordinatorOwner {
    func didFinish() {
        startedCoordinator = nil
    }
}

enum SearchSuggestionsRoute: Route {}

extension SearchSuggestionsCoordinator: Navigating {
    typealias R = SearchSuggestionsRoute
    
    func showNext(_ route: SearchSuggestionsRoute) {
        
    }
}
