//
//  SearchBarViewModel.swift
//  catowser
//
//  Created by Andrei Ermoshin on 1/4/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import Foundation
import SwiftUI
import CoreBrowser
import FeaturesFlagsKit
import BrowserNetworking
import CottonCoreBaseKit

final class SearchBarViewModel: NSObject {
    @Published var showSuggestions: Bool
    @Published var searchQuery: String
    @Published var state: SearchBarState
    /// Temporary property which automatically removes leading spaces.
    /// Can't declare it private due to compiler error.
    @LeadingTrimmed private var tempSearchText: String
    
    private var searchSuggestClient: SearchEngine {
        let optionalXmlData = ResourceReader.readXmlSearchPlugin(with: FeatureManager.searchPluginName(), on: .main)
        guard let xmlData = optionalXmlData else {
            return .googleSearchEngine()
        }
        
        let osDescription: OpenSearch.Description
        do {
            osDescription = try OpenSearch.Description(data: xmlData)
        } catch {
            print("Open search xml parser error: \(error.localizedDescription)")
            return .googleSearchEngine()
        }
        
        return osDescription.html
    }
    
    override init() {
        showSuggestions = false
        searchQuery = ""
        tempSearchText = ""
        state = .blankSearch
        super.init()
    }
}

private extension SearchBarViewModel {
    func replaceTab(with url: URL, with suggestion: String? = nil) {
        let blockPopups = DefaultTabProvider.shared.blockPopups
        let isJSEnabled = FeatureManager.boolValue(of: .javaScriptEnabled)
        let settings = Site.Settings(isPrivate: false,
                                     blockPopups: blockPopups,
                                     isJSEnabled: isJSEnabled,
                                     canLoadPlugins: true)
        guard let site = Site(url, suggestion, settings) else {
            assertionFailure("\(#function) failed to replace current tab - failed create site")
            return
        }
        try? TabsListManager.shared.replaceSelected(.site(site))
    }
}

extension SearchBarViewModel: SearchSuggestionsListDelegate {
    func didSelect(_ content: SuggestionType) {
        showSuggestions = false
        switch content {
        case .looksLikeURL(let likeURL):
            guard let url = URL(string: likeURL) else {
                assertionFailure("Failed construct site URL using edited URL")
                return
            }
            replaceTab(with: url)
        case .knownDomain(let domain):
            guard let url = URL(string: "https://\(domain)") else {
                assertionFailure("Failed construct site URL using domain name")
                return
            }
            replaceTab(with: url)
        case .suggestion(let suggestion):
            guard let url = searchSuggestClient.searchURLForQuery(suggestion) else {
                assertionFailure("Failed construct search engine url from suggestion string")
                return
            }
            replaceTab(with: url, with: suggestion)
        }
    }
}

extension SearchBarViewModel: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchQuery: String) {
        if searchQuery.isEmpty || searchQuery.looksLikeAURL() {
            showSuggestions = false
        } else {
            showSuggestions = true
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
        state = .startSearch
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        state = .cancelTapped
        showSuggestions = false
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
        didSelect(content)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // called when `Cancel` pressed or search bar no more a first responder
    }
}
