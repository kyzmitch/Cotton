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
    ) -> any SearchSuggestionsViewModel {
        SearchSuggestionsViewModelImpl(autocompleteUseCase, context)
    }
    
    /// Web view model
    public static func createWebViewVM(
        _ context: any WebViewContext,
        _ resolveDnsUseCase: any ResolveDNSUseCase,
        _ selectTabUseCase: SelectedTabUseCase,
        _ replaceTabUseCase: ReplaceSelectedTabUseCase,
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
        _ readTabUseCase: ReadSelectedTabIdUseCase,
        _ closeTabUseCase: CloseTabUseCase,
        _ selectTabUseCase: SelectTabUseCase,
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
        _ addTabUseCase: AddTabUseCase
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
        _ writeTabsUseCase: ReplaceSelectedTabUseCase,
        _ createSearchURLUseCase: CreateSearchURLUseCase,
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
        _ readTabUseCase: ReadAllTabsUseCase,
        _ readSelectedIdUseCase: ReadSelectedTabIdUseCase,
        _ writeTabUseCase: CloseTabUseCase,
        _ selectUseCase: SelectTabUseCase,
        _ addTabUseCase: AddTabUseCase,
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
