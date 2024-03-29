//
//  SearchBarViewModel.swift
//  catowser
//
//  Created by Andrei Ermoshin on 1/4/23.
//  Copyright © 2023 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation
import SwiftUI
import CoreBrowser
import FeaturesFlagsKit
import BrowserNetworking
import CottonBase

/// An analog of existing SearchBar coordinator, but for SwiftUI
/// and at the same time it implements `SearchSuggestionsListDelegate`
/// and `UISearchBarDelegate` which couldn't be implemented in SwiftUI view.
/// This class is only needed for SwiftUI mode when it uses old UKit view controller.
@MainActor
final class SearchBarViewModel: NSObject, ObservableObject {
    /// Based on values from observed delegates and search bar state it is possible to tell
    /// if search suggestions view can be showed or no.
    @Published var showSearchSuggestions: Bool
    /// Search query which is empty by default and won't look like URL
    @Published var searchQuery: String
    /// Current action which is initiated by User to search bar which would be handled in SwiftUI view
    @Published var action: SearchBarAction
    /// Temporary property which automatically removes leading spaces.
    /// Can't declare it private due to compiler error.
    @LeadingTrimmed private var tempSearchText: String

    override init() {
        showSearchSuggestions = false
        searchQuery = ""
        tempSearchText = ""
        action = .clearView
        super.init()
    }
}

private extension SearchBarViewModel {
    func replaceTab(with url: URL, with suggestion: String? = nil, _ isJSEnabled: Bool) async {
        let blockPopups = DefaultTabProvider.shared.blockPopups
        let settings = Site.Settings(isPrivate: false,
                                     blockPopups: blockPopups,
                                     isJSEnabled: isJSEnabled,
                                     canLoadPlugins: true)
        guard let site = Site(url, suggestion, settings) else {
            assertionFailure("\(#function) failed to replace current tab - failed create site")
            return
        }
        /// TODO: think how to replace delegate with view model func and WriteTabUseCase
        _ = await TabsDataService.shared.sendCommand(.replaceSelectedContent(.site(site)))
    }
}

extension SearchBarViewModel: SearchSuggestionsListDelegate {
    func searchSuggestionDidSelect(_ content: SuggestionType) async {
        showSearchSuggestions = false

        let isJSEnabled = await FeatureManager.shared.boolValue(of: .javaScriptEnabled)
        switch content {
        case .looksLikeURL(let likeURL):
            guard let url = URL(string: likeURL) else {
                assertionFailure("Failed construct site URL using edited URL")
                return
            }
            await replaceTab(with: url, with: nil, isJSEnabled)
        case .knownDomain(let domain):
            guard let url = URL(string: "https://\(domain)") else {
                assertionFailure("Failed construct site URL using domain name")
                return
            }
            await replaceTab(with: url, with: nil, isJSEnabled)
        case .suggestion(let suggestion):
            let client = await HttpEnvironment.shared.searchSuggestClient()
            guard let url = client.searchURLForQuery(suggestion) else {
                assertionFailure("Failed construct search engine url from suggestion string")
                return
            }
            await replaceTab(with: url, with: suggestion, isJSEnabled)
        }
    }
}

extension SearchBarViewModel: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchQuery: String) {
        if searchQuery.isEmpty || searchQuery.looksLikeAURL() {
            showSearchSuggestions = false
        } else {
            showSearchSuggestions = true
            self.searchQuery = searchQuery
        }
    }

    func searchBar(_ searchBar: UISearchBar,
                   shouldChangeTextIn range: NSRange,
                   replacementText text: String) -> Bool {
        guard let value = searchBar.text else {
            return text != " "
        }
        // UIKit's searchbar delegate uses modern String type
        // but at the same time legacy NSRange type
        // which can't be used in String API,
        // since it requires modern Range<String.Index>
        // https://exceptionshub.com/nsrange-to-rangestring-index.html
        let future = (value as NSString).replacingCharacters(in: range, with: text)
        // Only need to check that no leading spaces
        // trailing space is allowed to be able to construct
        // query requests with more than one word.
        tempSearchText = future
        // 400 IQ approach
        return tempSearchText == future
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        action = .startSearch
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        action = .cancelTapped
        showSearchSuggestions = false
        searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else {
            return
        }
        let content: SuggestionType
        if text.looksLikeAURL() {
            content = .looksLikeURL(text)
        } else {
            // need to open web view with url of search engine
            // and specific search queue
            content = .suggestion(text)
        }
        Task {
            await searchSuggestionDidSelect(content)
        }
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // called when `Cancel` pressed or search bar no more a first responder
    }
}
