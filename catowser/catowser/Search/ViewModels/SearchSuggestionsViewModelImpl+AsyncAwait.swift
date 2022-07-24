//
//  SearchSuggestionsViewModelImpl+AsyncAwait.swift
//  catowser
//
//  Created by Andrei Ermoshin on 7/24/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

#if swift(>=5.5)

 import Foundation

 /// Can't make them private to allow compilation on Xcode 12.x
 extension SearchSuggestionsViewModelImpl {
     @available(swift 5.5)
     @available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
     func aaFetchSuggestions(_ query: String, _ domainNames: [String]) async {
         let taskHandler = Task.detached(priority: .userInitiated) { [weak self] () -> [String] in
             guard let self = self else {
                 throw AppError.zombieSelf
             }
             return try await self.autocomplete.aaFetchSuggestions(query)
         }
         searchSuggestionsTaskHandler = taskHandler
         do {
             await updateState(try await taskHandler.value, domainNames)
         } catch {
             print("Fail to fetch search suggestions \(error.localizedDescription)")
             await updateState([], domainNames)
         }
     }
     
     @available(swift 5.5)
     @available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
     @MainActor
     private func updateState(_ suggestions: [String], _ domainNames: [String]) async {
         aaState = .everythingLoaded(domainNames, suggestions)
     }
 }

 #endif
