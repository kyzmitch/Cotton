//
//  ViewModelFactory.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/21/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import FeaturesFlagsKit
import CoreHttpKit

final class ViewModelFactory {
    static let shared: ViewModelFactory = .init()
    
    private init() {}
    
    func searchSuggestionsViewModel() -> SearchSuggestionsViewModel {
        let searchProviderType = FeatureManager.webSearchAutoCompleteValue()

        switch searchProviderType {
        case .google:
            let context = GoogleContext(HttpEnvironment.shared.googleClient,
                                        HttpEnvironment.shared.googleClientRxSubscriber,
                                        HttpEnvironment.shared.googleClientSubscriber)
            let strategy = GoogleAutocompleteStrategy(context)
            return SearchSuggestionsViewModelImpl(strategy)
        case .duckduckgo:
            let context = DDGoContext(HttpEnvironment.shared.duckduckgoClient,
                                      HttpEnvironment.shared.duckduckgoClientRxSubscriber,
                                      HttpEnvironment.shared.duckduckgoClientSubscriber)
            let strategy = DDGoAutocompleteStrategy(context)
            return SearchSuggestionsViewModelImpl(strategy)
        }
    }
    
    func webViewModel(_ settings: Site.Settings, _ context: WebViewContext) -> WebViewModel {
        let stratContext = GoogleDNSContext(HttpEnvironment.shared.dnsClient,
                                       HttpEnvironment.shared.dnsClientRxSubscriber,
                                       HttpEnvironment.shared.dnsClientSubscriber)
        
        let strategy = GoogleDNSStrategy(stratContext)
        return WebViewModelImpl(strategy, settings, context)
    }
}
