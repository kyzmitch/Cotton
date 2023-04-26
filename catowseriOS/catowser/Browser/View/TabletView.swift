//
//  TabletView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 1/13/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI
import CoreBrowser

struct TabletView<C: BrowserContentCoordinators>: View {
    // MARK: - view models of subviews
    
    private var model: MainBrowserModel<C>
    private let searchBarVM: SearchBarViewModel
    private let browserContentVM: BrowserContentViewModel
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
    }
    
    var body: some View {
        switch mode {
        case .compatible:
            uiKitWrapperView
        case .full:
            Spacer()
        }
    }
    
    private var uiKitWrapperView: some View {
        VStack {
            let searchBarDelegate: UISearchBarDelegate = searchBarVM
            TabletTabsView(mode)
            TabletSearchBarView(searchBarDelegate, $searchBarAction, toolbarVM, $webViewInterface, mode)
            if showProgress {
                ProgressView(value: websiteLoadProgress)
            }
            if showSearchSuggestions {
                let delegate = searchBarVM
                SearchSuggestionsView($searchQuery, delegate, mode)
            } else {
                let jsPlugins = browserContentVM.jsPluginsBuilder
                BrowserContentView(jsPlugins, toolbarVM, $isLoading, $contentType, $webViewNeedsUpdate, mode)
            }
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
            contentType = value
            showSearchSuggestions = false
        }
        .onReceive(browserContentVM.$contentType) { searchBarAction = .create($0) }
        .onReceive(browserContentVM.$loading.dropFirst()) { isLoading = $0 }
    }
}

#if DEBUG
struct TabletView_Previews: PreviewProvider {
    static var previews: some View {
        let model = MainBrowserModel(DummyDelegate())
        TabletView(model, .compatible)
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (3rd generation)"))
    }
}
#endif