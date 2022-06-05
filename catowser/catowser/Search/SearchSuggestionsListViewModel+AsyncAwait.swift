//
//  SearchSuggestionsListViewModel+AsyncAwait.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/5/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

#if swift(>=5.5)

import Foundation
import HttpKit

/// Can't make them private to allow compilation on Xcode 12.x
extension SearchSuggestionsListViewModelImpl {
    @available(swift 5.5)
    @available(iOS 15.0, *)
    @MainActor
    private func updateSuggestions(_ suggestions: [String]) async {
        self.suggestions = suggestions
    }
    
    @available(swift 5.5)
    @available(iOS 15.0, *)
    func aaPrepareSearch(for searchText: String) async {
        searchSuggestionTaskHandler?.cancel()
        let taskHandler = detach(priority: .userInitiated) { [weak self] () -> [String] in
            guard let self = self else {
                throw AppError.zombieSelf
            }
            let response = try await self.googleClient.aaGoogleSearchSuggestions(for: searchText)
            return response.textResults
        }
        searchSuggestionTaskHandler = taskHandler
        do {
            await updateSuggestions( try await taskHandler.get())
        } catch {
            print("Fail to fetch search suggestions \(error.localizedDescription)")
            await updateSuggestions([])
        }
    }
}

#endif
