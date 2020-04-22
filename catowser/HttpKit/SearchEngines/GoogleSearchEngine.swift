//
//  GoogleSearchEngine.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 4/13/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation

extension HttpKit.SearchEngine {
    public static func googleSearchEngine() -> HttpKit.SearchEngine {
        let items: [URLQueryItem] = [
            URLQueryItem(name: "ie", value: "utf-8"),
            URLQueryItem(name: "oe", value: "utf-8"),
            URLQueryItem(name: "client", value: "firefox")
        ]
        
        return HttpKit.SearchEngine(shortName: "Google",
                                    domainName: "www.google.com",
                                    path: "search",
                                    queryItems: items, imageData: nil)
    }
}
