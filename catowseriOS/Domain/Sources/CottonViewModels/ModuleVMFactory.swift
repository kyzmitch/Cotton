//
//  ModuleVMFactory.swift
//  catowser
//
//  Created by Andrey Ermoshin on 17.12.2024.
//  Copyright © 2024 Cotton (Catowser). All rights reserved.
//

import CottonBase
import CoreBrowser
import CottonUseCases
import FeatureFlagsKit
import ViewModelKit

/// Factory for the view models in this framework to hide actual implementations
@MainActor public final class ModuleVMFactory {
    private init() { }
    /// Search suggestions view model
    public static func createSearchSuggestionsVM(
        _ autocompleteUseCase: any FetchAutocompleteSuggestionsUseCase,
        _ context: SearchViewContext
    ) -> SearchSuggestionsViewModel {
        SearchSuggestionsViewModelImpl(autocompleteUseCase, context)
    }

    /// Web view model
    public static func createWebViewVM(
        _ context: any WebViewContext,
        _ resolveDnsUseCase: any ResolveDNSUseCase,
        _ selectTabUseCase: any SelectedTabUseCase,
        _ replaceTabUseCase: any ReplaceSelectedTabUseCase,
        _ siteNavigation: SiteExternalNavigationDelegate?,
        _ site: Site? = nil
    ) -> any WebViewModel {
        WebViewModelImpl(
            context,
            resolveDnsUseCase,
            selectTabUseCase,
            replaceTabUseCase,
            siteNavigation,
            site
        )
    }

    /// tab view model
    public static func createTabVM(
        _ tab: CoreBrowser.Tab,
        _ readTabUseCase: any ReadSelectedTabIdUseCase,
        _ closeTabUseCase: any CloseTabUseCase,
        _ selectTabUseCase: any SelectTabUseCase,
        _ context: TabViewModelContext,
        _ featureManager: FeatureManager.StateHolder
    ) -> TabViewModel {
        TabViewModelImpl(
            tab,
            readTabUseCase,
            closeTabUseCase,
            selectTabUseCase,
            context,
            FeatureManager.shared
        )
    }

    /// all tabs view model
    public static func createAllTabsVM(
        _ addTabUseCase: any AddTabUseCase
    ) -> AllTabsViewModel {
        AllTabsViewModelImpl(addTabUseCase)
    }

    /// Toolbar view model
    public static func createToolbarVM(
        _ appContext: BrowserToolbarViewContext
    ) -> BrowserToolbarViewModel {
        BrowserToolbarViewModelImpl(appContext)
    }

    /// Search bar view model
    public static func createSearchBarVM(
        _ writeTabsUseCase: any ReplaceSelectedTabUseCase,
        _ createSearchURLUseCase: any CreateSearchURLUseCase,
        _ appContext: SearchBarContext
    ) -> SearchBarViewModelWithDelegates {
        SearchBarViewModelImpl(
            writeTabsUseCase,
            createSearchURLUseCase,
            appContext
        )
    }

    /// Tab previews view model
    public static func createTabPreviewsVM(
        _ readTabUseCase: any ReadAllTabsUseCase,
        _ readSelectedIdUseCase: any ReadSelectedTabIdUseCase,
        _ writeTabUseCase: any CloseTabUseCase,
        _ selectUseCase: any SelectTabUseCase,
        _ addTabUseCase: any AddTabUseCase,
        _ appContext: TabPreviewsAppContext
    ) -> TabsPreviewsViewModelWithHolder {
        TabsPreviewsViewModelImpl(
            readTabUseCase,
            readSelectedIdUseCase,
            writeTabUseCase,
            selectUseCase,
            addTabUseCase,
            appContext
        )
    }
}
