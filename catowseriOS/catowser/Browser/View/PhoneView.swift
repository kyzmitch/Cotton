//
//  PhoneView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 1/13/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI
import CoreBrowser
import FeaturesFlagsKit
import CottonPlugins

struct PhoneView: View {
    // MARK: - view models of subviews

    @StateObject private var searchBarVM: SearchBarViewModel = .init()
    /// A reference to created vm in main view
    @ObservedObject private var browserContentVM: BrowserContentViewModel
    /// Toolbar model needed by both UI modes
    @StateObject private var toolbarVM: BrowserToolbarViewModel = .init()
    
    // MARK: - search bar state
    
    /// Search bar action is only needed for SwiftUI UIKit wrapper
    @State private var searchBarAction: SearchBarAction
    /// Search suggestion visibility state
    @State private var showSearchSuggestions: Bool
    /// Search query string state which is set by SearchBar and used by SearchSuggestions
    @State private var searchQuery: String
    /// Needs to be fetched from global actor in task to know current value
    @State private var searchProviderType: WebAutoCompletionSource
    
    // MARK: - web content loading state
    
    @State private var showProgress: Bool
    @State private var websiteLoadProgress: Double
    
    // MARK: - browser content state
    
    @State private var isLoading: Bool
    @State private var contentType: Tab.ContentType = .blank
    /// A workaround to avoid unnecessary web view updates
    @State private var webViewNeedsUpdate: Bool
    
    // MARK: - web view related
    
    @State private var webViewInterface: WebViewNavigatable?
    
    // MARK: - constants
    
    private let mode: SwiftUIMode
    
    // MARK: - toolbar
    
    @State private var toolbarVisibility: Visibility
    @State private var showingMenu: Bool
    @State private var showingTabs: Bool
    @State private var tabsCount: Int
    
    // MARK: - menu
    
    @State private var isDohEnabled: Bool
    @State private var isJavaScriptEnabled: Bool
    @State private var nativeAppRedirectEnabled: Bool
    
    private var menuModel: MenuViewModel {
        let style: BrowserMenuStyle
        if let interface = webViewInterface {
            style = .withSiteMenu(interface.host, interface.siteSettings)
        } else {
            style = .onlyGlobalMenu
        }
        
        return MenuViewModel(style, isDohEnabled, isJavaScriptEnabled, nativeAppRedirectEnabled)
    }
    
    init(_ browserContentVM: BrowserContentViewModel, _ mode: SwiftUIMode) {
        self.browserContentVM = browserContentVM
        // Browser content state has to be stored outside in main view
        // to allow keep current state value when `showSearchSuggestions`
        // state variable changes
        isLoading = true
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
        switch mode {
        case .compatible:
            toolbarVisibility = .hidden
        case .full:
            toolbarVisibility = .visible
        }
        tabsCount = 0
        showingMenu = false
        showingTabs = false
        
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
            PhoneSearchBarLegacyView(searchBarDelegate, searchBarAction)
                .frame(minWidth: 0, maxWidth: .infinity, maxHeight: CGFloat.searchViewHeight)
            if showProgress {
                ProgressView(value: websiteLoadProgress)
            }
            if showSearchSuggestions {
                let delegate: SearchSuggestionsListDelegate = searchBarVM
                SearchSuggestionsView(searchQuery, delegate, mode, searchProviderType)
            } else {
                let jsPlugins = browserContentVM.jsPluginsBuilder
                let siteNavigation: SiteExternalNavigationDelegate = toolbarVM
                BrowserContentView(jsPlugins, siteNavigation, isLoading, contentType, $webViewNeedsUpdate, mode)
            }
            ToolbarView(toolbarVM, $webViewInterface)
        }
        .ignoresSafeArea(.keyboard, edges: [.bottom])
        .ignoresSafeArea(.container, edges: [.leading, .trailing])
        .onReceive(toolbarVM.$showProgress) { showProgress = $0 }
        .onReceive(toolbarVM.$websiteLoadProgress) { websiteLoadProgress = $0 }
        .onReceive(searchBarVM.$showSearchSuggestions) { showSearchSuggestions = $0 }
        .onReceive(searchBarVM.$searchQuery) { searchQuery = $0 }
        .onReceive(searchBarVM.$action.dropFirst()) { searchBarAction = $0 }
        .onReceive(toolbarVM.$stopWebViewReuseAction.dropFirst()) { webViewNeedsUpdate = false }
        .onReceive(browserContentVM.$webViewNeedsUpdate.dropFirst()) { webViewNeedsUpdate = true }
        .onReceive(browserContentVM.$contentType) { value in
            showSearchSuggestions = false
            contentType = value
        }
        .onReceive(browserContentVM.$loading.dropFirst()) { isLoading = $0 }
        .task {
            // Fetch data asynhroniously from Global actor:
            searchProviderType = await FeatureManager.shared.webSearchAutoCompleteValue()
            isDohEnabled = await FeatureManager.shared.boolValue(of: .dnsOverHTTPSAvailable)
            isJavaScriptEnabled = await FeatureManager.shared.boolValue(of: .javaScriptEnabled)
            nativeAppRedirectEnabled = await FeatureManager.shared.boolValue(of: .nativeAppRedirect)
            contentType = await DefaultTabProvider.shared.contentState
        }
    }
    
    private var fullySwiftUIView: some View {
        NavigationView {
            VStack {
                SearchBarViewV2($searchQuery, $searchBarAction)
                    .frame(minWidth: 0, maxWidth: .infinity)
                if showProgress {
                    ProgressView(value: websiteLoadProgress)
                }
                if showSearchSuggestions {
                    let delegate: SearchSuggestionsListDelegate = searchBarVM
                    SearchSuggestionsView(searchQuery, delegate, mode, searchProviderType)
                } else {
                    let jsPlugins = browserContentVM.jsPluginsBuilder
                    let siteNavigation: SiteExternalNavigationDelegate = toolbarVM
                    BrowserContentView(jsPlugins, siteNavigation, isLoading, contentType, $webViewNeedsUpdate, mode)
                }
            }
            .toolbar {
                ToolbarViewV2(toolbarVM, tabsCount, $showingMenu, $showingTabs, $showSearchSuggestions)
            }
        }
        .sheet(isPresented: $showingMenu) {
            BrowserMenuView(menuModel)
        }
        .sheet(isPresented: $showingTabs) {
            TabsPreviewsLegacyView()
        }
        .ignoresSafeArea(.keyboard, edges: [.bottom])
        .ignoresSafeArea(.container, edges: [.leading, .trailing])
        .onReceive(toolbarVM.$showProgress) { showProgress = $0 }
        .onReceive(toolbarVM.$websiteLoadProgress) { websiteLoadProgress = $0 }
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
        .onChange(of: showingTabs) { newValue in
            // Reset the search bar from editing mode
            // when new modal screen is about to get shown
            if newValue {
                searchBarAction = .cancelTapped
            }
        }
        .onReceive(browserContentVM.$loading.dropFirst()) { isLoading = $0 }
        .task {
            // Fetch data asynhroniously from Global actor:
            searchProviderType = await FeatureManager.shared.webSearchAutoCompleteValue()
            isDohEnabled = await FeatureManager.shared.boolValue(of: .dnsOverHTTPSAvailable)
            isJavaScriptEnabled = await FeatureManager.shared.boolValue(of: .javaScriptEnabled)
            nativeAppRedirectEnabled = await FeatureManager.shared.boolValue(of: .nativeAppRedirect)
            contentType = await DefaultTabProvider.shared.contentState
        }
    }
}

#if DEBUG
struct PhoneView_Previews: PreviewProvider {
    static var previews: some View {
        let source: DummyJSPluginsSource = .init()
        let bvm: BrowserContentViewModel = .init(source, .blank)
        PhoneView(bvm, .full)
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
    }
}
#endif
