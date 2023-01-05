//
//  MainBrowserView.swift
//  catowser
//
//  Created by Andrey Ermoshin on 10.12.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI
import CoreBrowser

struct MainBrowserView<C: BrowserContentCoordinators>: View {
    @ObservedObject var model: MainBrowserModel<C>
    
    var body: some View {
        _MainBrowserView<C>(model: model)
            .environment(\.browserContentCoordinators, model.coordinatorsInterface)
    }
}

private struct _MainBrowserView<C: BrowserContentCoordinators>: View {
    // MARK: - view models of subviews
    
    @ObservedObject private var model: MainBrowserModel<C>
    private let browserContentModel: BrowserContentModel
    private let toolbarModel: WebBrowserToolbarModel
    private let searchBarModel: SearchBarViewModel
    
    // MARK: - web content loading state
    
    @State private var websiteLoadProgress: Double
    @State private var showProgress: Bool
    
    // MARK: - search bar state
    
    @State private var showSearchSuggestions: Bool
    @State private var searchQuery: String
    @State private var searchBarState: SearchBarState
    
    // MARK: - browser content state
    
    @State private var isLoading: Bool
    @State private var contentType: Tab.ContentType
    /// A workaround to avoid unnecessary web view updates
    @State private var webViewNeedsUpdate: Bool
    
    init(model: MainBrowserModel<C>) {
        // Browser content state has to be stored outside in main view
        // to allow keep current state value when `showSearchSuggestions`
        // state variable changes
        isLoading = true
        contentType = DefaultTabProvider.shared.contentState
        webViewNeedsUpdate = false
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
        // Toolbar should know if current web view changes to provide navigation
        ViewsEnvironment.shared.reuseManager.addObserver(toolbarModel)
    }
    
    var body: some View {
        if isPad {
            tabletView()
        } else {
            phoneView()
        }
    }
}

private extension _MainBrowserView {
    func tabletView() -> some View {
        VStack {
            Spacer()
        }
    }
    
    func phoneView() -> some View {
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
            ToolbarView(toolbarModel)
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
        .onReceive(searchBarModel.$searchViewState.dropFirst(1)) { value in
            searchBarState = value
        }
        .onReceive(toolbarModel.$stopWebViewReuseAction.dropFirst(1)) { _ in
            webViewNeedsUpdate = false
        }
        .onReceive(browserContentModel.$webViewNeedsUpdate.dropFirst(1)) { _ in
            webViewNeedsUpdate = true
        }
    }
}

#if DEBUG
class DummyDelegate: BrowserContentCoordinators {
    let topSitesCoordinator: TopSitesCoordinator? = nil
    let webContentCoordinator: WebContentCoordinator? =  nil
    let globalMenuDelegate: GlobalMenuDelegate? = nil
    let toolbarCoordinator: MainToolbarCoordinator? = nil
    let toolbarPresenter: AnyViewController? = nil
}

struct MainBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        let model = MainBrowserModel(DummyDelegate())
        MainBrowserView(model: model)
    }
}
#endif
