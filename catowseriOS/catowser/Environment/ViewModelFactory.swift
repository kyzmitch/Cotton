//
//  ViewModelFactory.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/21/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation
import CottonBase
import CottonData
import CoreBrowser
import FeaturesFlagsKit

/// Creates new instances of view models.
/// Depends on feature flags to determine VM configuration/dependencies.
///
/// It doesn't need to be globalActor even tho it is a singleton,
/// because it doesn't hold the state and vm creation is synchronous.
@MainActor
final class ViewModelFactory {
    static let shared: ViewModelFactory = .init()

    private init() {}

    func searchSuggestionsViewModel(_ searchProviderType: WebAutoCompletionSource) async -> any SearchSuggestionsViewModel {
        let vmContext: SearchViewContextImpl = .init()
        switch searchProviderType {
        case .google:
            let type = (any AutocompleteSearchUseCase).self
            let autocompleteUseCase = await UseCaseFactory.shared.findUseCase(type, .googleAutocompleteUseCase)
            return SearchSuggestionsViewModelImpl(autocompleteUseCase, vmContext)
        case .duckduckgo:
            let type = (any AutocompleteSearchUseCase).self
            let autocompleteUseCase = await UseCaseFactory.shared.findUseCase(type, .duckDuckGoAutocompleteUseCase)
            return SearchSuggestionsViewModelImpl(autocompleteUseCase, vmContext)
        }
    }

    func getWebViewModel(_ site: Site?,
                         _ context: WebViewContext,
                         _ siteNavigation: SiteExternalNavigationDelegate?) async -> any WebViewModel {
        let type = (any ResolveDNSUseCase).self
        let googleDnsUseCase = await UseCaseFactory.shared.findUseCase(type, .googleResolveDnsUseCase)
        let selectTabUseCase = await UseCaseFactory.shared.findUseCase(SelectedTabUseCase.self)
        let writeUseCase = await UseCaseFactory.shared.findUseCase(WriteTabsUseCase.self)
        return WebViewModelImpl(googleDnsUseCase, context, selectTabUseCase, writeUseCase, siteNavigation, site)
    }

    func tabViewModel(_ tab: Tab) async -> TabViewModel {
        let readUseCase = await UseCaseFactory.shared.findUseCase(ReadTabsUseCase.self)
        let writeUseCase = await UseCaseFactory.shared.findUseCase(WriteTabsUseCase.self)
        return TabViewModel(tab, readUseCase, writeUseCase)
    }

    func tabsPreviewsViewModel() async -> TabsPreviewsViewModel {
        let readUseCase = await UseCaseFactory.shared.findUseCase(ReadTabsUseCase.self)
        let writeUseCase = await UseCaseFactory.shared.findUseCase(WriteTabsUseCase.self)
        return TabsPreviewsViewModel(readUseCase, writeUseCase)
    }

    func allTabsViewModel() async -> AllTabsViewModel {
        let writeUseCase = await UseCaseFactory.shared.findUseCase(WriteTabsUseCase.self)
        return AllTabsViewModel(writeUseCase)
    }

    func topSitesViewModel() async -> TopSitesViewModel {
        let isJsEnabled = await FeatureManager.shared.boolValue(of: .javaScriptEnabled)
        let writeUseCase = await UseCaseFactory.shared.findUseCase(WriteTabsUseCase.self)
        let sites = await DefaultTabProvider.shared.topSites(isJsEnabled)
        return TopSitesViewModel(sites, writeUseCase)
    }
}
