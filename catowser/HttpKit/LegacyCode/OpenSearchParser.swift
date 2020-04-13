//
//  OpenSearchParser.swift
//  catowser
//
//  Created by Andrei Ermoshin on 15/02/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

/// OpenSearch XML parser.
public struct OpenSearchParser {
    public static func parse(_ file: String, engineID: String) throws -> HttpKit.SearchEngine {
        // TODO: make real XML parsing
        // For now just return object configured/hardcoded for Google
        return .googleSearchEngine()
    }
}
