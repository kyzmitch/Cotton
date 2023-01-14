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
    
    init(_ model: MainBrowserModel<C>) {
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
    }
    
    var body: some View {
        /*
         - ignoresSafeArea(.keyboard)
         Allows to not have the toolbar be attached to keyboard.
         So, the toolbar will stay on same position
         even after keyboard became visible.
         */
        
        VStack {
            SearchBarView(searchBarModel, $searchBarState)
            if showProgress {
                ProgressView(value: websiteLoadProgress)
            }
            if showSearchSuggestions {
                SearchSuggestionsView($searchQuery, searchBarModel)
            } else {
                BrowserContentView(browserContentModel, toolbarModel, $isLoading, $contentType, $webViewNeedsUpdate)
            }
            ToolbarView(toolbarModel, $webViewInterface)
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
    }
}

#if DEBUG
struct PhoneView_Previews: PreviewProvider {
    static var previews: some View {
        let model = MainBrowserModel(DummyDelegate())
        PhoneView(model)
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
    }
}
#endif
