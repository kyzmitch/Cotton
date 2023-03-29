//
//  SearchSuggestionsView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 1/4/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI

struct SearchSuggestionsView: View {
    @Binding private var searchQuery: String
    private weak var delegate: SearchSuggestionsListDelegate?
    private let mode: SwiftUIMode
    
    init(_ searchQuery: Binding<String>,
         _ delegate: SearchSuggestionsListDelegate?,
         _ mode: SwiftUIMode) {
        _searchQuery = searchQuery
        self.delegate = delegate
        self.mode = mode
    }
    
    var body: some View {
        switch mode {
        case .compatible:
            SearchSuggestionsLegacyView($searchQuery, delegate)
        case .full:
            SearchSuggestionsViewV2($searchQuery, delegate)
        }
        
    }
}

private struct SearchSuggestionsLegacyView: UIViewControllerRepresentable {
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

#if DEBUG
struct SearchSuggestionsView_Previews: PreviewProvider {
    static var previews: some View {
        let state: Binding<String> = .init {
            "cotton"
        } set: { _ in
            //
        }
        SearchSuggestionsView(state, nil, .compatible)
    }
}
#endif
