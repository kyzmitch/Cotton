//
//  ViewModelFactory.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/21/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import CottonBase
import CottonViewModels
import CottonUseCases
import CoreBrowser
import FeatureFlagsKit
import FeatureFlags

/// Creates new instances of view models.
/// Depends on feature flags to determine VM configuration/dependencies.
///
/// It doesn't need to be globalActor even tho it is a singleton,
/// because it doesn't hold the state and vm creation is synchronous.
@MainActor final class ViewModelFactory {
    static let shared: ViewModelFactory = .init()

    private let useCaseRegistry: UseCaseRegistry.StateHolder
    private let featureManager: FeatureManager.StateHolder
    private let defaultTabProvider: DefaultTabProvider.StateHolder

    private init(
        _ useCaseRegistry: UseCaseRegistry.StateHolder = UseCaseRegistry.shared,
        _ featureManager: FeatureManager.StateHolder = FeatureManager.shared,
        _ defaultTabProvider: DefaultTabProvider.StateHolder = DefaultTabProvider.shared
    ) {
        self.useCaseRegistry = useCaseRegistry
        self.featureManager = featureManager
        self.defaultTabProvider = defaultTabProvider
    }

    func searchSuggestionsViewModel() async -> SearchSuggestionsViewModel {
        let vmContext: SearchViewContextImpl = .init()
        let autocompleteUseCase = await useCaseRegistry.findUseCase((any FetchAutocompleteSuggestionsUseCase).self)
        return ModuleVMFactory.createSearchSuggestionsVM(
            autocompleteUseCase,
            vmContext
        )
    }

    func getWebViewModel(
        _ site: Site?,
        _ context: WebViewContext,
        _ siteNavigation: SiteExternalNavigationDelegate?
    ) async -> any WebViewModel {
        async let googleDnsUseCase = useCaseRegistry.findUseCase((any ResolveDNSUseCase).self)
        async let selectTabUseCase = useCaseRegistry.findUseCase((any SelectedTabUseCase).self)
        async let replaceTabUseCase = useCaseRegistry.findUseCase((any ReplaceSelectedTabUseCase).self)
        return await ModuleVMFactory.createWebViewVM(
            context,
            googleDnsUseCase,
            selectTabUseCase,
            replaceTabUseCase,
            siteNavigation,
            site
        )
    }

    func tabViewModel(
        _ tab: CoreBrowser.Tab,
        _ context: TabViewModelContext
    ) async -> TabViewModel {
        async let readUseCase = useCaseRegistry.findUseCase((any ReadSelectedTabIdUseCase).self)
        async let closeTabUseCase = useCaseRegistry.findUseCase((any CloseTabUseCase).self)
        async let selectTabUseCase = useCaseRegistry.findUseCase((any SelectTabUseCase).self)
        return await ModuleVMFactory.createTabVM(
            tab,
            readUseCase,
            closeTabUseCase,
            selectTabUseCase,
            context,
            FeatureManager.shared
        )
    }

    func tabsPreviewsViewModel(
        _ context: TabPreviewsAppContext
    ) async -> TabsPreviewsViewModelWithHolder {
        async let readUseCase = useCaseRegistry.findUseCase((any ReadAllTabsUseCase).self)
        async let readSelectedIdUseCase = useCaseRegistry.findUseCase((any ReadSelectedTabIdUseCase).self)
        async let closeTabUseCase = useCaseRegistry.findUseCase((any CloseTabUseCase).self)
        async let selectTabUseCase = useCaseRegistry.findUseCase((any SelectTabUseCase).self)
        async let addTabUseCase = useCaseRegistry.findUseCase((any AddTabUseCase).self)
        return await ModuleVMFactory.createTabPreviewsVM(
            readUseCase,
            readSelectedIdUseCase,
            closeTabUseCase,
            selectTabUseCase,
            addTabUseCase,
            context
        )
    }

    func allTabsViewModel() async -> AllTabsViewModel {
        let writeUseCase = await useCaseRegistry.findUseCase((any AddTabUseCase).self)
        return ModuleVMFactory.createAllTabsVM(writeUseCase)
    }

    func topSitesViewModel() async -> TopSitesViewModel {
        let isJsEnabled = await featureManager.boolValue(of: .javaScriptEnabled)
        async let sites = defaultTabProvider.topSites(isJsEnabled)
        async let replaceTabUseCase = useCaseRegistry.findUseCase((any ReplaceSelectedTabUseCase).self)
        return await ModuleVMFactory.createTopSitesVM(sites, replaceTabUseCase)
    }

    func searchBarViewModel(
        _ context: SearchBarContext
    ) async -> SearchBarViewModelWithDelegates {
        async let writeUseCase = useCaseRegistry.findUseCase((any ReplaceSelectedTabUseCase).self)
        async let searchUseCase = useCaseRegistry.findUseCase((any CreateSearchURLUseCase).self)
        return await ModuleVMFactory.createSearchBarVM(
            writeUseCase,
            searchUseCase,
            context
        )
    }

    func toolbarViewModel() -> BrowserToolbarViewModel {
        let context = BrowserToolbarViewContextImpl()
        return ModuleVMFactory.createToolbarVM(context)
    }
}
