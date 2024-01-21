//
//  ViewModelFactory.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/21/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import CottonBase
import CottonData
import CoreBrowser

/// Creates new instances of view models.
/// Depends on feature flags to determine VM configuration/dependencies.
///
/// It doesn't need to be globalActor even tho it is a singleton,
/// because it doesn't hold the state and vm creation is synchronous.
final class ViewModelFactory {
    static let shared: ViewModelFactory = .init()
    
    private init() {}
    
    func searchSuggestionsViewModel(_ searchProviderType: WebAutoCompletionSource) -> SearchSuggestionsViewModel {
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
    
    @MainActor func webViewModel(_ site: Site, _ context: WebViewContext) async -> WebViewModel {
        /// It is the same context for any site or view model, maybe it makes sense to use only one
        let stratContext = GoogleDNSContext(HttpEnvironment.shared.dnsClient,
                                            HttpEnvironment.shared.dnsClientRxSubscriber,
                                            HttpEnvironment.shared.dnsClientSubscriber)
        
        let strategy = GoogleDNSStrategy(stratContext)
        let selectTabUseCase = await UseCaseFactory.shared().findUseCase(SelectedTabUseCase.self)
        let writeUseCase = await UseCaseFactory.shared().findUseCase(WriteTabsUseCase.self)
        return WebViewModelImpl(strategy, site, context, selectTabUseCase, writeUseCase)
    }
    
    @MainActor func tabViewModel(_ tab: Tab) async -> TabViewModel {
        let readUseCase = await UseCaseFactory.shared().findUseCase(ReadTabsUseCase.self)
        let writeUseCase = await UseCaseFactory.shared().findUseCase(WriteTabsUseCase.self)
        return TabViewModel(tab, readUseCase, writeUseCase)
    }
    
    @MainActor func tabsPreviewsViewModel() async -> TabsPreviewsViewModel {
        let readUseCase = await UseCaseFactory.shared().findUseCase(ReadTabsUseCase.self)
        let writeUseCase = await UseCaseFactory.shared().findUseCase(WriteTabsUseCase.self)
        return TabsPreviewsViewModel(readUseCase, writeUseCase)
    }
    
    @MainActor func allTabsViewModel() async -> AllTabsViewModel {
        let writeUseCase = await UseCaseFactory.shared().findUseCase(WriteTabsUseCase.self)
        return AllTabsViewModel(writeUseCase)
    }
}
