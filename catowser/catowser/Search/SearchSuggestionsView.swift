//
//  SearchSuggestionsView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 1/4/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI

struct SearchSuggestionsView: View {
    @Binding var searchQuery: String
    weak var delegate: SearchSuggestionsListDelegate?
    
    var body: some View {
        SearchSuggestionsLegacyView(searchQuery: $searchQuery, delegate: delegate)
    }
}

private struct SearchSuggestionsLegacyView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    
    @Binding var searchQuery: String
    weak var delegate: SearchSuggestionsListDelegate?
    
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
