//
//  ViewModelFactory.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/21/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import FeaturesFlagsKit
import CottonBase
import CoreCatowser

final class ViewModelFactory {
    static let shared: ViewModelFactory = .init()
    
    private init() {}
    
    func searchSuggestionsViewModel() -> SearchSuggestionsViewModel {
        let searchProviderType = FeatureManager.webSearchAutoCompleteValue()
        let vmContext: SearchViewContextImpl = .init()
        switch searchProviderType {
        case .google:
            let context = GoogleContext(HttpEnvironment.shared.googleClient,
                                        HttpEnvironment.shared.googleClientRxSubscriber,
                                        HttpEnvironment.shared.googleClientSubscriber)
            let strategy = GoogleAutocompleteStrategy(context)
            return SearchSuggestionsViewModelImpl(strategy, vmContext)
        case .duckduckgo:
            let context = DDGoContext(HttpEnvironment.shared.duckduckgoClient,
                                      HttpEnvironment.shared.duckduckgoClientRxSubscriber,
                                      HttpEnvironment.shared.duckduckgoClientSubscriber)
            let strategy = DDGoAutocompleteStrategy(context)
            return SearchSuggestionsViewModelImpl(strategy, vmContext)
        }
    }
    
    func webViewModel(_ site: Site, _ context: WebViewContext) -> WebViewModel {
        // It is the same context for any site or view model
        // maybe it makes sense to use only one
        let stratContext = GoogleDNSContext(HttpEnvironment.shared.dnsClient,
                                       HttpEnvironment.shared.dnsClientRxSubscriber,
                                       HttpEnvironment.shared.dnsClientSubscriber)
        
        let strategy = GoogleDNSStrategy(stratContext)
        return WebViewModelImpl(strategy, site, context)
    }
}
