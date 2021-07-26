//
//  SearchSuggestionsViewController+AsyncAwait.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/15/21.
//  Copyright © 2021 andreiermoshin. All rights reserved.
//

#if swift(>=5.5)

import Foundation
import HttpKit
#if canImport(_Concurrency)
// this won't be needed after Swift 5.5 will be released
import _Concurrency
#endif

/// Can't make them private to allow compilation on Xcode 12.x
extension SearchSuggestionsViewController {
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
            let response = await try self.googleClient.aaGoogleSearchSuggestions(for: searchText)
            return response.textResults
        }
        searchSuggestionTaskHandler = taskHandler
        do {
            await updateSuggestions(await try taskHandler.get())
        } catch {
            print("Fail to fetch search suggestions \(error.localizedDescription)")
            await updateSuggestions([])
        }
    }
}

#endif
