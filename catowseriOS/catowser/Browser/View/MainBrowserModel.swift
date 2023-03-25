//
//  MainBrowserViewModel.swift
//  catowser
//
//  Created by Andrey Ermoshin on 14.12.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Combine
import SwiftUI
import JSPlugins

/* @MainActor */ final class MainBrowserViewModel<C: BrowserContentCoordinators>: ObservableObject {
    weak var coordinatorsInterface: C?
    /// Not a constant because can't be initialized in init
    lazy var jsPluginsBuilder: any JSPluginsSource = {
        JSPluginsBuilder().setBase(self).setInstagram(self)
    }()
    
    // MARK: - search bar state
    
    @Published var searchBarState: SearchBarState
    @Published var showSearchSuggestions: Bool
    @Published var searchQuery: String
    
    // MARK: - init
    
    init(_ coordinator: C?) {
        coordinatorsInterface = coordinator
        // Search bar and suggestions state values
        // have to be stored in main VM
        // to be able to replace browser content view
        // with the search suggestions view when necessary
        searchBarState = .blankSearch
        showSearchSuggestions = false
        searchQuery = ""
    }
}

extension MainBrowserViewModel: InstagramContentDelegate {
    func didReceiveVideoNodes(_ nodes: [InstagramVideoNode]) {
    }
}

extension MainBrowserViewModel: BasePluginContentDelegate {
    func didReceiveVideoTags(_ tags: [HTMLVideoTag]) {
    }
}
