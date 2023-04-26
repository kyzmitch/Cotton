//
//  PhoneView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 1/13/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI
import CoreBrowser

struct PhoneView<C: BrowserContentCoordinators>: View {
    // MARK: - view models of subviews
    
    private var model: MainBrowserModel<C>
    private let searchBarVM: SearchBarViewModel
    private let browserContentVM: BrowserContentViewModel
    /// Toolbar model needed by both UI modes
    private let toolbarVM: BrowserToolbarViewModel
    
    // MARK: - search bar state
    
    /// Search bar action is only needed for SwiftUI UIKit wrapper
    @State private var searchBarAction: SearchBarAction
    /// Search suggestion visibility state
    @State private var showSearchSuggestions: Bool
    /// Search query string state which is set by SearchBar and used by SearchSuggestions
    @State private var searchQuery: String
    
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
    
    // MARK: - toolbar
    
    @State private var toolbarVisibility: Visibility
    @State private var showingMenu: Bool
    @State private var showingTabs: Bool
    @State private var tabsCount: Int
    
    private var menuModel: MenuViewModel {
        let style: BrowserMenuStyle
        if let interface = webViewInterface {
            style = .withSiteMenu(interface.host, interface.siteSettings)
        } else {
            style = .onlyGlobalMenu
        }
        
        return MenuViewModel(style)
    }
    
    init(_ model: MainBrowserModel<C>, _ mode: SwiftUIMode) {
        // Browser content state has to be stored outside in main view
        // to allow keep current state value when `showSearchSuggestions`
        // state variable changes
        isLoading = true
        contentType = DefaultTabProvider.shared.contentState
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
        // Store references to subview models in the main view
        // to be able to subscribe for the publishers
        self.model = model
        browserContentVM = BrowserContentViewModel(model.jsPluginsBuilder)
        toolbarVM = BrowserToolbarViewModel()
        searchBarVM = SearchBarViewModel()
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
            // Search query binding is not needed for UIKit mode, but we still have to pass it
            SearchBarView(searchBarDelegate, $searchQuery, $searchBarAction, mode)
            if showProgress {
                ProgressView(value: websiteLoadProgress)
            }
            if showSearchSuggestions {
                let delegate: SearchSuggestionsListDelegate = searchBarVM
                SearchSuggestionsView($searchQuery, delegate, mode)
            } else {
                let jsPlugins = browserContentVM.jsPluginsBuilder
                BrowserContentView(jsPlugins, toolbarVM, $isLoading, $contentType, $webViewNeedsUpdate, mode)
            }
            ToolbarView(toolbarVM, $webViewInterface)
        }
        .ignoresSafeArea(.keyboard)
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
    }
    
    private var fullySwiftUIView: some View {
        NavigationView {
            VStack {
                SearchBarView(nil, $searchQuery, $searchBarAction, mode)
                if showProgress {
                    ProgressView(value: websiteLoadProgress)
                }
                if showSearchSuggestions {
                    let delegate: SearchSuggestionsListDelegate = searchBarVM
                    SearchSuggestionsView($searchQuery, delegate, mode)
                } else {
                    let jsPlugins = browserContentVM.jsPluginsBuilder
                    BrowserContentView(jsPlugins, toolbarVM, $isLoading, $contentType, $webViewNeedsUpdate, mode)
                }
            }
            .toolbar {
                ToolbarViewV2(toolbarVM, $tabsCount, $showingMenu, $showingTabs, $showSearchSuggestions)
            }
        }
        .sheet(isPresented: $showingMenu) {
            BrowserMenuView(menuModel)
        }
        .sheet(isPresented: $showingTabs) {
            TabsPreviewsLegacyView()
        }
        .ignoresSafeArea(.keyboard)
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
    }
}

#if DEBUG
struct PhoneView_Previews: PreviewProvider {
    static var previews: some View {
        let model = MainBrowserModel(DummyDelegate())
        PhoneView(model, .full)
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
    }
}
#endif