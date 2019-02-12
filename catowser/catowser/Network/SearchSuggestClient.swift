//
//  SearchSuggestClient.swift
//  catowser
//
//  Created by Andrey Ermoshin on 25/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//

import Foundation
import UIKit

protocol WebPageDescription {
    var webAddress: URL {get set}
    var title: String {get set}
    var shortDescription: String {get set}
    var icon: UIImage {get set}
}

protocol WebSearchResult {
    var searchEngineName: String {get set}
    var numberOfSearchResults: Int {get set}
    func searchResultDescription(for number: Int) -> WebPageDescription
}

protocol TextWebSearchResult: WebSearchResult {
    var searchedText: String {get set}
}

extension TextWebSearchResult {
    func searchedKeywords() -> [String] {
        return searchedText.split(separator: " ").filter {$0.count >= 3}.map {String($0)}
    }
}

protocol ImageWebSearchResult: WebSearchResult {
    var searchedImage: UIImage {get set}
}

enum SearchResult {
    case NoResult(Error?)
    // for example if search queury was "open" then
    // result array should give something like:
    // ["openoffice", "openvpn", "opencv",...]
    // and these strings could be used as titles for
    // buttons in stack view to allow user
    // to select from suggested quick variants
    // without typing whole query
    case TextSuccess([String])
    case ImageSuccess([UIImage])
}

typealias SearchSuggestionsCallback = (_ response: SearchResult) -> Void

protocol SearchClient {
    var httpClient: HttpApi { get set }
    var searchEngine: WebSearchEngine {get set}
    var textSearchCallback: SearchSuggestionsCallback {get set}
    
    init(webSearchEngine: WebSearchEngine, webClient: NetworkClientType, textSearchHandler: @escaping SearchSuggestionsCallback)
    func searchText(searchQuery: String)
    func searchImage(searchedImage: UIImage)
}

class SearchSuggestClient<HttpClientType: HttpApi>: SearchClient {
    typealias NetworkClientType = HttpClientType
    var httpClient: HttpClientType
    var searchEngine: WebSearchEngine
    var textSearchCallback: SearchSuggestionsCallback
    
    required init(webSearchEngine: WebSearchEngine, webClient: HttpClientType, textSearchHandler: @escaping SearchSuggestionsCallback) {
        searchEngine = webSearchEngine
        httpClient = webClient
        textSearchCallback = textSearchHandler
    }
    
    func searchText(searchQuery: String) {
        
    }
    
    func searchImage(searchedImage: UIImage) {
        
    }
}
