//
//  GoogleSearchEndpoint+AsyncAwait.swift
//  HttpKit
//
//  Created by Ermoshin Andrey on 20.06.2021.
//  Copyright © 2021 andreiermoshin. All rights reserved.
//

#if swift(>=5.5)

import HttpKit

extension HttpKit.Client where Server == GoogleServer {
    @available(swift 5.5)
    @available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public func aaGoogleSearchSuggestions(for text: String) async throws -> GoogleSearchSuggestionsResponse {
        let endpoint: GSearchEndpoint = try .googleSearchSuggestions(query: text)
        let value = try await self.aaMakePublicRequest(for: endpoint, responseType: endpoint.responseType)
        return value
    }
}

#endif
