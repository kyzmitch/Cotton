//
//  SearchEngine.swift
//  catowser
//
//  Created by Andrei Ermoshin on 15/02/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

extension HttpKit {
    public struct SearchEngine {
        /// Name e.g. "DuckDuckGo"
        private let shortName: String
        /// Valid components for final URL
        private let components: URLComponents
        /// Original query items
        private let queryItems: [URLQueryItem]
        
        init(shortName: String, domainName: String, path: String, queryItems: [URLQueryItem]) {
            self.shortName = shortName
            
            var components = URLComponents()
            components.scheme = "https"
            components.host = domainName
            components.path = path
            self.components = components
            self.queryItems = queryItems
        }

        /// Returns the search URL for the given query.
        ///
        /// - Parameter query: Text entered by user in search view.
        /// - Returns: URL
        public func searchURLForQuery(_ query: String) -> URL? {
            var mutableComponents = components
            let item = URLQueryItem(name: "q", value: query)
            var items = queryItems
            items.append(item)
            mutableComponents.queryItems = items
            
            return mutableComponents.url
        }
    }
}
