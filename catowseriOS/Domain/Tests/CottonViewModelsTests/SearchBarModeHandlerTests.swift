//
//  SearchBarModeHandlerTests.swift
//  CottonViewModelsTests
//

import Testing
@testable import CottonViewModels

@MainActor
private final class DummySearchBarContext: SearchBarStateContext {
    func searchSuggestionDidSelect(_ content: SuggestionType) async throws {}
}

struct SearchBarModeHandlerTests {
    @MainActor
    @Test func viewModeStartSearchMovesToSearchMode() async throws {
        let state = SearchBarInViewMode<DummySearchBarContext>("overlay", "content")
        let next = try await state.modeHandler.transition(
            state,
            on: .startSearch("query"),
            with: nil
        )
        #expect(next is SearchBarInSearchMode<DummySearchBarContext>)
        #expect(next.query == "query")
    }

    @MainActor
    @Test func viewModeRejectsCancelSearch() async {
        let state = SearchBarInViewMode<DummySearchBarContext>()
        await #expect(throws: SearchBarError.self) {
            try await state.modeHandler.transition(
                state,
                on: .cancelSearch,
                with: nil
            )
        }
    }

    @MainActor
    @Test func searchModeCancelReturnsToViewMode() async throws {
        let state = SearchBarInSearchMode<DummySearchBarContext>("q", "o", "c")
        let next = try await state.modeHandler.transition(
            state,
            on: .cancelSearch,
            with: nil
        )
        #expect(next is SearchBarInViewMode<DummySearchBarContext>)
        #expect(next.overlayContent == "o")
        #expect(next.searchBarContent == "c")
    }

    @MainActor
    @Test func searchModeRejectsStartSearch() async {
        let state = SearchBarInSearchMode<DummySearchBarContext>(nil, nil, nil)
        await #expect(throws: SearchBarError.self) {
            try await state.modeHandler.transition(
                state,
                on: .startSearch("again"),
                with: nil
            )
        }
    }
}
