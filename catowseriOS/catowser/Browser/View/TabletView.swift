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
    
    @StateObject private var model: MainBrowserViewModel<C>
    private let searchBarModel: SearchBarViewModel
    private let browserContentModel: BrowserContentModel
    private let toolbarModel: WebBrowserToolbarModel
    
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
    
    init(_ coordinator: C?, _ mode: SwiftUIMode) {
        let internalModel = MainBrowserViewModel(coordinator)
        _model = .init(wrappedValue: internalModel)
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

        // Store references to subview models in the main view
        // to be able to subscribe for the publishers

        browserContentModel = BrowserContentModel(_model.wrappedValue.jsPluginsBuilder)
        toolbarModel = WebBrowserToolbarModel()
        searchBarModel = SearchBarViewModel()
        self.mode = mode
    }
    
    var body: some View {
        VStack {
            TabletTabsView()
            TabletSearchBarView(searchBarModel, $model.searchBarState, toolbarModel, $webViewInterface)
            if showProgress {
                ProgressView(value: websiteLoadProgress)
            }
            if model.showSearchSuggestions {
                SearchSuggestionsView($model.searchQuery, searchBarModel)
            } else {
                BrowserContentView(browserContentModel, toolbarModel, $isLoading, $contentType, $webViewNeedsUpdate)
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
            model.showSearchSuggestions = value
        }
        .onReceive(searchBarModel.$searchText) { value in
            model.searchQuery = value
        }
        .onReceive(searchBarModel.$searchViewState.dropFirst()) { value in
            model.searchBarState = value
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
struct TabletView_Previews: PreviewProvider {
    static var previews: some View {
        let coordinator = DummyDelegate()
        TabletView(coordinator, .compatible)
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (3rd generation)"))
    }
}
#endif
