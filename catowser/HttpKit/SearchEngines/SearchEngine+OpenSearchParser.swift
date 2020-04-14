//
//  SearchEngine+OpenSearchParser.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 4/14/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import SWXMLHash

public enum OpenSearchError: LocalizedError {
    case invalidFile
}

public extension HttpKit.SearchEngine {
    init(_ file: String, engineID: String) throws {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: file)) else {
            throw OpenSearchError.invalidFile
        }

        _ = SWXMLHash.config { (options) in
                options.detectParsingErrors = true
        }.parse(data)
        
        self = HttpKit.SearchEngine.googleSearchEngine()
    }
}
