//
//  SearchEngine.swift
//  catowser
//
//  Created by Andrei Ermoshin on 15/02/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import Alamofire // only for Http method type

extension HttpKit {
    /// Provides URLs for HTML content type to use it in web views
    public struct SearchEngine {
        /// Name e.g. "DuckDuckGo"
        let shortName: String
        /// Valid components for final URL
        let components: URLComponents
        /// Original query items
        let queryItems: [URLQueryItem]
        /// Data for site image/icon
        let imageData: Data?
        /// So far not used parameter,  but it present in OpenSearch format
        let httpMethod: HTTPMethod
        
        init(shortName: String,
             domainName: String,
             path: String,
             queryItems: [URLQueryItem],
             imageData: Data? = nil,
             httpMethod: HTTPMethod = .get) {
            self.shortName = shortName
            
            var components = URLComponents()
            components.scheme = "https"
            components.host = domainName
            components.path = path
            self.components = components
            self.queryItems = queryItems
            self.imageData = imageData
            self.httpMethod = httpMethod
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
