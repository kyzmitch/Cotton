//
//  SearchSuggestionsLegacyView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/21/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI
import CottonData

struct SearchSuggestionsLegacyView: CatowserUIVCRepresentable {
    typealias UIViewControllerType = UIViewController
    
    private let searchQuery: String
    private weak var delegate: SearchSuggestionsListDelegate?
    private let viewModel: SearchSuggestionsViewModel
    
    init(_ searchQuery: String,
         _ delegate: SearchSuggestionsListDelegate?,
         _ viewModel: SearchSuggestionsViewModel) {
        self.searchQuery = searchQuery
        self.delegate = delegate
        self.viewModel = viewModel
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let vc = vcFactory.searchSuggestionsViewController(delegate, viewModel)
        return vc.viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        guard let interface = uiViewController as? SearchSuggestionsControllerInterface else {
            return
        }
        Task {
            await interface.prepareSearch(for: searchQuery)
        }
    }
}
