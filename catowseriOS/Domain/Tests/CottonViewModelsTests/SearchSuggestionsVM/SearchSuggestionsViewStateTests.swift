//
//  SearchSuggestionsViewStateTests.swift
//  CottonViewModelsTests
//

import Testing
@testable import CottonViewModels

struct SearchSuggestionsViewStateTests {
    let known1 = ["google.com", "gmail.com"]
    let expected1 = ["google", "gmail"]

    @Test func waitingForQuery() {
        let state: SearchSuggestionsState = .waitingForQuery
        #expect(state == .waitingForQuery)
        #expect(state.rowsCount(Int.random(in: -1000...1000)) == 0)
        #expect(state.sectionsNumber == 0)
        let row = Int.random(in: -1000...1000)
        let section = Int.random(in: -1000...1000)
        #expect(state.value(from: row, section: section) == nil)
    }

    @Test func knownDomainsLoaded() {
        let state: SearchSuggestionsState = .knownDomainsLoaded(known1)
        #expect(state == .knownDomainsLoaded(known1))
        #expect(state.rowsCount(Int.random(in: -1000...1000)) == known1.count)
        #expect(state.sectionsNumber == 1)
        let section = Int.random(in: -1000...1000)
        #expect(state.value(from: 3, section: section) == nil)
        #expect(state.value(from: 0, section: section) == known1[0])
        #expect(state.value(from: 1, section: section) == known1[1])
    }

    @Test func everythingLoaded() {
        let state: SearchSuggestionsState = .everythingLoaded(known1, expected1)
        #expect(state == .everythingLoaded(known1, expected1))
        #expect(state.rowsCount(0) == known1.count)
        #expect(state.rowsCount(1) == expected1.count)
        #expect(state.rowsCount(-1) == -1)
    }

    @Test func createInitialIsWaitingForQuery() {
        #expect(SearchSuggestionsState.createInitial() == .waitingForQuery)
    }
}
