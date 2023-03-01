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
        showingMenu = false
    }
    
    var body: some View {
        /*
         - ignoresSafeArea(.keyboard)
         Allows to not have the toolbar be attached to keyboard.
         So, the toolbar will stay on same position
         even after keyboard became visible.
         */
        switch mode {
        case .compatible:
            VStack {
                SearchBarView(searchBarModel, $searchBarState, mode)
                if showProgress {
                    ProgressView(value: websiteLoadProgress)
                }
                if showSearchSuggestions {
                    SearchSuggestionsView($searchQuery, searchBarModel)
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
            .onReceive(searchBarModel.$searchText) { value in
                searchQuery = value
            }
            .onReceive(searchBarModel.$searchViewState.dropFirst()) { value in
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
                    SearchBarView(searchBarModel, $searchBarState, mode)
                    if showProgress {
                        ProgressView(value: websiteLoadProgress)
                    }
                    if showSearchSuggestions {
                        SearchSuggestionsView($searchQuery, searchBarModel)
                    } else {
                        BrowserContentView(browserContentModel,
                                           toolbarModel,
                                           $isLoading,
                                           $contentType,
                                           $webViewNeedsUpdate)
                    }
                    if case .compatible = mode {
                        ToolbarView(toolbarModel, $webViewInterface)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            toolbarModel.goBack()
                        } label: {
                            Image("nav-back")
                        }
                        .disabled(toolbarModel.goBackDisabled)
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Spacer()
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            toolbarModel.goForward()
                        } label: {
                            Image("nav-forward")
                        }
                        .disabled(toolbarModel.goForwardDisabled)
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Spacer()
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            toolbarModel.reload()
                        } label: {
                            Image("nav-refresh")
                        }
                        .disabled(toolbarModel.reloadDisabled)
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Spacer()
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            showingMenu.toggle()
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingMenu) {
                BrowserMenuView(model: menuModel)
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
            .onReceive(searchBarModel.$searchText) { value in
                searchQuery = value
            }
            .onReceive(searchBarModel.$searchViewState.dropFirst()) { value in
                searchBarState = value
            }
            .onReceive(toolbarModel.$stopWebViewReuseAction.dropFirst()) { _ in
                webViewNeedsUpdate = false
            }
            .onReceive(browserContentModel.$webViewNeedsUpdate.dropFirst()) { _ in
                webViewNeedsUpdate = true
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