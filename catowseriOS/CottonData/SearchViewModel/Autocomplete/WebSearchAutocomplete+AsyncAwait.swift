//
//  WebSearchAutocomplete+AsyncAwait.swift
//  catowser
//
//  Created by Andrei Ermoshin on 7/24/22.
//  Copyright © 2022 Cotton (former Catowser). All rights reserved.
//

#if swift(>=5.5)

import Foundation

extension WebSearchAutocomplete {
    @available(swift 5.5)
    @available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func aaFetchSuggestions(_ query: String) async throws -> [String] {
        let response = try await strategy.suggestionsTask(for: query)
        return response.textResults
    }
}

#endif
