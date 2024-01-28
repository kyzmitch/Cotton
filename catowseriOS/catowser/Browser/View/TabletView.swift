//
//  TabletView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 1/13/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI
import CoreBrowser
import FeaturesFlagsKit
import CottonData

struct TabletView: View {
    // MARK: - view models of subviews
    
    @StateObject private var searchBarVM: SearchBarViewModel = .init()
    /// A reference to created vm in main view
    @ObservedObject private var browserContentVM: BrowserContentViewModel
    /// Toolbar model needed by both UI modes
    @StateObject private var toolbarVM: BrowserToolbarViewModel = .init()
    /// Top sites view model is async dependency, so, can only be injected from outside
    @ObservedObject private var topSitesVM: TopSitesViewModel
    /// Search suggestions view model has async init
    private let searchSuggestionsVM: SearchSuggestionsViewModel
    /// Web view model without a specific site
    private let webVM: any WebViewModel
    
    // MARK: - Tablet search bar state
    
    /// Search bar action is only needed for SwiftUI UIKit wrapper
    @State private var searchBarAction: SearchBarAction
    /// Search suggestion visibility state
    @State private var showSearchSuggestions: Bool
    /// Search query string state which is set by SearchBar and used by SearchSuggestions
    @State private var searchQuery: String
    /// Tells if browser menu needs to be shown
    @State private var showingMenu: Bool
    /// Tabs counter
    @State private var tabsCount: Int
    /// Needs to be fetched from global actor in task to know current value
    @State private var searchProviderType: WebAutoCompletionSource
    
    // MARK: - web content loading state
    
    @State private var showProgress: Bool
    @State private var websiteLoadProgress: Double
    
    // MARK: - browser content state
    
    @State private var isLoading: Bool
    @State private var contentType: Tab.ContentType
    /// A workaround to avoid unnecessary web view updates
    @State private var webViewNeedsUpdate: Bool
    
    // MARK: - web view related
    
    @State private var webViewInterface: WebViewNavigatable?
    
    // MARK: - constants
    
    private let mode: SwiftUIMode
    
    // MARK: - menu
    
    @State private var isDohEnabled: Bool
    @State private var isJavaScriptEnabled: Bool
    @State private var nativeAppRedirectEnabled: Bool
    @ObservedObject private var allTabsVM: AllTabsViewModel
    
    private var menuModel: MenuViewModel {
        let style: BrowserMenuStyle
        if let interface = webViewInterface {
            style = .withSiteMenu(interface.host, interface.siteSettings)
        } else {
            style = .onlyGlobalMenu
        }
        
        return MenuViewModel(style, isDohEnabled, isJavaScriptEnabled, nativeAppRedirectEnabled)
    }
    
    init(_ browserContentVM: BrowserContentViewModel, 
         _ mode: SwiftUIMode,
         _ defaultContentType: Tab.ContentType,
         _ allTabsVM: AllTabsViewModel,
         _ topSitesVM: TopSitesViewModel,
         _ searchSuggestionsVM: SearchSuggestionsViewModel,
         _ webVM: any WebViewModel) {
        self.browserContentVM = browserContentVM
        self.topSitesVM = topSitesVM
        self.searchSuggestionsVM = searchSuggestionsVM
        self.allTabsVM = allTabsVM
        self.webVM = webVM
        // Browser content state has to be stored outside in main view
        // to allow keep current state value when `showSearchSuggestions`
        // state variable changes
        isLoading = true
        self.contentType = defaultContentType
        webViewNeedsUpdate = false
        webViewInterface = nil
        // web content loading state has to be stored here
        // to get that info from toolbar model and use it
        // for `ProgressView`
        showProgress = false
        websiteLoadProgress = 0.0
        // Search bar and suggestions state values
        // have to be stored in main view
        // to be able to replace browser content view
        // with the search suggestions view when necessary
        showSearchSuggestions = false
        searchQuery = ""
        searchBarAction = .clearView
        self.mode = mode
        showingMenu = false
        tabsCount = 0
        
        // Next states are set to some random "good" values
        // because actualy values need to be fetched from Global actor
        
        searchProviderType = .google
        isDohEnabled = false
        isJavaScriptEnabled = true
        nativeAppRedirectEnabled = true
    }
    
    var body: some View {
        switch mode {
        case .compatible:
            uiKitWrapperView
        case .full:
            fullySwiftUIView
        }
    }
    
    private var uiKitWrapperView: some View {
        VStack {
            let searchBarDelegate: UISearchBarDelegate = searchBarVM
            TabletTabsView(mode, allTabsVM)
            TabletSearchBarLegacyView(searchBarDelegate, searchBarAction, webViewInterface)
                .frame(height: .toolbarViewHeight)
            // this should be the same with the value in `SearchBarBaseViewController`
            if showProgress {
                ProgressView(value: websiteLoadProgress)
            }
            if showSearchSuggestions {
                let delegate: SearchSuggestionsListDelegate = searchBarVM
                SearchSuggestionsView(searchQuery, delegate, mode, searchSuggestionsVM)
            } else {
                let jsPlugins = browserContentVM.jsPluginsBuilder
                let siteNavigation: SiteExternalNavigationDelegate = toolbarVM
                BrowserContentView(jsPlugins, 
                                   siteNavigation,
                                   isLoading,
                                   contentType,
                                   $webViewNeedsUpdate,
                                   mode,
                                   topSitesVM,
                                   webVM)
            }
        }
        .ignoresSafeArea(.keyboard)
        .onReceive(toolbarVM.$showProgress) { showProgress = $0 }
        .onReceive(toolbarVM.$websiteLoadProgress) { websiteLoadProgress = $0 }
        .onReceive(toolbarVM.$webViewInterface) { webViewInterface = $0 }
        .onReceive(searchBarVM.$showSearchSuggestions) { showSearchSuggestions = $0 }
        .onReceive(searchBarVM.$searchQuery) { searchQuery = $0 }
        .onReceive(searchBarVM.$action.dropFirst()) { searchBarAction = $0 }
        .onReceive(toolbarVM.$stopWebViewReuseAction.dropFirst()) { webViewNeedsUpdate = false }
        .onReceive(browserContentVM.$webViewNeedsUpdate.dropFirst()) { webViewNeedsUpdate = true }
        .onReceive(browserContentVM.$contentType) { value in
            contentType = value
            showSearchSuggestions = false
        }
        .onReceive(browserContentVM.$contentType) { searchBarAction = .create($0) }
        .onReceive(browserContentVM.$loading.dropFirst()) { isLoading = $0 }
        .task {
            // Fetch data asynhroniously from Global actor:
            searchProviderType = await FeatureManager.shared.webSearchAutoCompleteValue()
            isDohEnabled = await FeatureManager.shared.boolValue(of: .dnsOverHTTPSAvailable)
            isJavaScriptEnabled = await FeatureManager.shared.boolValue(of: .javaScriptEnabled)
            nativeAppRedirectEnabled = await FeatureManager.shared.boolValue(of: .nativeAppRedirect)
            webVM.siteNavigation = toolbarVM
        }
    }
    
    private var fullySwiftUIView: some View {
        VStack {
            TabletTabsView(mode, allTabsVM)
            TabletSearchBarViewV2($showingMenu, $showSearchSuggestions, $searchQuery, $searchBarAction)
                .frame(height: .toolbarViewHeight)
                .environmentObject(toolbarVM)
            if showProgress {
                ProgressView(value: websiteLoadProgress)
            }
            if showSearchSuggestions {
                let delegate: SearchSuggestionsListDelegate = searchBarVM
                SearchSuggestionsView(searchQuery, delegate, mode, searchSuggestionsVM)
            } else {
                let jsPlugins = browserContentVM.jsPluginsBuilder
                let siteNavigation: SiteExternalNavigationDelegate = toolbarVM
                BrowserContentView(jsPlugins,
                                   siteNavigation,
                                   isLoading,
                                   contentType,
                                   $webViewNeedsUpdate,
                                   mode,
                                   topSitesVM,
                                   webVM)
            }
        }
        .sheet(isPresented: $showingMenu) {
            BrowserMenuView(menuModel)
        }
        .ignoresSafeArea(.keyboard)
        .onReceive(toolbarVM.$showProgress) { showProgress = $0 }
        .onReceive(toolbarVM.$websiteLoadProgress) { websiteLoadProgress = $0 }
        .onReceive(toolbarVM.$webViewInterface) { webViewInterface = $0 }
        .onReceive(searchBarVM.$showSearchSuggestions) { showSearchSuggestions = $0 }
        .onChange(of: searchQuery) { value in
            let inSearchMode = searchBarAction == .startSearch
            let validQuery = !value.isEmpty && !value.looksLikeAURL()
            showSearchSuggestions = inSearchMode && validQuery
        }
        .onReceive(toolbarVM.$stopWebViewReuseAction.dropFirst()) { webViewNeedsUpdate = false }
        .onReceive(browserContentVM.$webViewNeedsUpdate.dropFirst()) { webViewNeedsUpdate = true }
        .onReceive(browserContentVM.$contentType.dropFirst()) { value in
            showSearchSuggestions = false
            contentType = value
            searchBarAction = .create(value)
        }
        .onReceive(browserContentVM.$tabsCount) { tabsCount = $0 }
        .onReceive(browserContentVM.$loading.dropFirst()) { isLoading = $0 }
        .task {
            // Fetch data asynhroniously from Global actor:
            searchProviderType = await FeatureManager.shared.webSearchAutoCompleteValue()
            isDohEnabled = await FeatureManager.shared.boolValue(of: .dnsOverHTTPSAvailable)
            isJavaScriptEnabled = await FeatureManager.shared.boolValue(of: .javaScriptEnabled)
            nativeAppRedirectEnabled = await FeatureManager.shared.boolValue(of: .nativeAppRedirect)
            webVM.siteNavigation = toolbarVM
        }
    }
}
