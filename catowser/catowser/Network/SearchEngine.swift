//
//  SearchEngine.swift
//  catowser
//
//  Created by Andrei Ermoshin on 15/02/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import UIKit

struct SearchEngine {
    /// Name e.g. "DuckDuckGo"
    private let shortName: String
    /// Favicon for search web site
    private let image: UIImage
    /// Full address for search request with template params in it
    /// E.g. "https://duckduckgo.com/?q={searchTerms}&t=fpas"
    private let searchTemplate: String
    /// Address for suggestions request with template params in it
    /// Not all search web sites have it
    private let suggestTemplate: String?

    /// Returns the search suggestion URL for the given query.
    ///
    /// - Parameter query: Text entered by user in search view.
    /// - Returns: URL
    func suggestURLForQuery(_ query: String) -> URL? {
        guard let suggestTemplate = suggestTemplate else {
            return nil
        }
        return .getURLFromTemplate(suggestTemplate, query: query)
    }

    /// Returns the search URL for the given query.
    ///
    /// - Parameter query: Text entered by user in search view.
    /// - Returns: URL
    func searchURLForQuery(_ query: String) -> URL? {
        return .getURLFromTemplate(searchTemplate, query: query)
    }
}

fileprivate extension String {
    /// Template constant which is used as a query parameter
    static let searchTermComponent = "{searchTerms}"
}

fileprivate extension URL {
    static func getURLFromTemplate(_ searchTemplate: String, query: String) -> URL? {
        if let escapedQuery = query.addingPercentEncoding(withAllowedCharacters: .SearchTermsAllowed) {
            // Escape the search template as well in case it contains not-safe characters like symbols
            let templateAllowedSet = NSMutableCharacterSet()
            templateAllowedSet.formUnion(with: .URLAllowed)

            // Allow brackets since we use them in our template as our insertion point
            templateAllowedSet.formUnion(with: CharacterSet(charactersIn: "{}"))

            if let encodedSearchTemplate = searchTemplate.addingPercentEncoding(withAllowedCharacters: templateAllowedSet as CharacterSet) {
                let urlString = encodedSearchTemplate
                    .replacingOccurrences(of: String.searchTermComponent, with: escapedQuery, options: .literal, range: nil)
                return URL(string: urlString)
            }
        }

        return nil
    }
}

extension SearchEngine {
    /// Search engine configured for google endpoints, but firefox used as a client.
    /// Can't use own `catowser` param because it is ignored by Google with Http 400 error
    static let googleEngine: SearchEngine = SearchEngine(shortName: "Google", image: .googleImage, searchTemplate: "https://www.google.com/search?q={searchTerms}&ie=utf-8&oe=utf-8&client=firefox", suggestTemplate: "https://www.google.com/complete/search?client=firefox&q={searchTerms}")
}

extension UIImage {
    static var googleImage: UIImage {
        return UIImage()
    }
}
