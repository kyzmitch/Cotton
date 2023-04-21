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
    private let searchBarModel: SearchBarViewModel
    private let browserContentModel: BrowserContentModel
    /// Toolbar model needed by both UI modes
    private let toolbarModel: WebBrowserToolbarModel
    
    // MARK: - search bar state
    
    @State private var searchBarState: SearchBarState
    @State private var showSearchSuggestions: Bool
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
        searchBarState = .blankSearch
        // Store references to subview models in the main view
        // to be able to subscribe for the publishers
        self.model = model
        browserContentModel = BrowserContentModel(model.jsPluginsBuilder)
        toolbarModel = WebBrowserToolbarModel()
        searchBarModel = SearchBarViewModel()
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
            VStack {
                SearchBarView(searchBarModel, $searchQuery, $searchBarState, mode)
                if showProgress {
                    ProgressView(value: websiteLoadProgress)
                }
                if showSearchSuggestions {
                    SearchSuggestionsView($searchQuery, searchBarModel, mode)
                } else {
                    BrowserContentView(browserContentModel, toolbarModel, $isLoading, $contentType, $webViewNeedsUpdate)
                }
                if case .compatible = mode {
                    ToolbarView(toolbarModel, $webViewInterface)
                }
            }
            .ignoresSafeArea(.keyboard)
            .onReceive(toolbarModel.$showProgress) { value in
                showProgress = value
            }
            .onReceive(toolbarModel.$websiteLoadProgress) { value in
                websiteLoadProgress = value
            }
            .onReceive(searchBarModel.$showSuggestions) { value in
                showSearchSuggestions = value
            }
            .onReceive(searchBarModel.$searchQuery) { value in
                searchQuery = value
            }
            .onReceive(searchBarModel.$state.dropFirst()) { value in
                searchBarState = value
            }
            .onReceive(toolbarModel.$stopWebViewReuseAction.dropFirst()) { _ in
                webViewNeedsUpdate = false
            }
            .onReceive(browserContentModel.$webViewNeedsUpdate.dropFirst()) { _ in
                webViewNeedsUpdate = true
            }
        case .full:
            NavigationView {
                VStack {
                    SearchBarView(searchBarModel, $searchQuery, $searchBarState, mode)
                    if showProgress {
                        ProgressView(value: websiteLoadProgress)
                    }
                    if showSearchSuggestions {
                        SearchSuggestionsView($searchQuery, searchBarModel, mode)
                    } else {
                        BrowserContentView(browserContentModel,
                                           toolbarModel,
                                           $isLoading,
                                           $contentType,
                                           $webViewNeedsUpdate)
                    }
                }
                .toolbar {
                    ToolbarViewV2(toolbarModel, $tabsCount, $showingMenu, $showingTabs)
                }
            }
            .sheet(isPresented: $showingMenu) {
                BrowserMenuView(model: menuModel)
            }
            .sheet(isPresented: $showingTabs) {
                TabsPreviewsLegacyView()
            }
            .ignoresSafeArea(.keyboard)
            .onReceive(toolbarModel.$showProgress) { value in
                showProgress = value
            }
            .onReceive(toolbarModel.$websiteLoadProgress) { value in
                websiteLoadProgress = value
            }
            .onReceive(searchBarModel.$showSuggestions) { value in
                showSearchSuggestions = value
            }
            .onReceive(searchBarModel.$searchQuery) { value in
                searchQuery = value
                showSearchSuggestions = !value.isEmpty
            }
            .onReceive(searchBarModel.$state.dropFirst()) { value in
                searchBarState = value
            }
            .onReceive(toolbarModel.$stopWebViewReuseAction.dropFirst()) { _ in
                webViewNeedsUpdate = false
            }
            .onReceive(browserContentModel.$webViewNeedsUpdate.dropFirst()) { _ in
                webViewNeedsUpdate = true
            }
            .onReceive(browserContentModel.$contentType) { value in
                switch value {
                case .blank, .favorites, .topSites, .homepage:
                    searchBarState = .blankSearch
                case .site(let site):
                    searchBarState = .viewMode(site.title, site.searchBarContent, false)
                }
            }
            .onReceive(browserContentModel.$tabsCount) { value in
                tabsCount = value
            }
        } // switch
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
