//
//  SearchSuggestionsLegacyView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/21/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI

struct SearchSuggestionsLegacyView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    
    @Binding private var searchQuery: String
    private weak var delegate: SearchSuggestionsListDelegate?
    
    init(_ searchQuery: Binding<String>,
         _ delegate: SearchSuggestionsListDelegate?) {
        _searchQuery = searchQuery
        self.delegate = delegate
    }
    
    private var vcFactory: ViewControllerFactory {
        ViewsEnvironment.shared.vcFactory
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let vc = vcFactory.searchSuggestionsViewController(delegate)
        return vc.viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        guard let interface = uiViewController as? SearchSuggestionsControllerInterface else {
            return
        }
        interface.prepareSearch(for: searchQuery)
    }
}
