//
//  SearchBarModeHandlerTests.swift
//  CottonViewModelsTests
//

import Testing
@testable import CottonViewModels

@MainActor
private final class RecordingSearchBarStateContext: SearchBarStateContext {
    private(set) var selectedSuggestions: [SuggestionType] = []
    var errorToThrow: Error?

    func searchSuggestionDidSelect(_ content: SuggestionType) async throws {
        if let errorToThrow {
            throw errorToThrow
        }
        selectedSuggestions.append(content)
    }
}

private enum RecordingError: Error {
    case intentional
}

struct SearchBarModeHandlerTests {

    // MARK: - SearchBarInvalidModeHandler

    @MainActor
    @Test func invalidModeHandlerThrowsForAnyAction() async {
        let state = SearchBarState<RecordingSearchBarStateContext>()
        #expect(state.modeHandler is SearchBarInvalidModeHandler<RecordingSearchBarStateContext>)

        for action in SearchBarAction.allCases {
            await #expect(throws: SearchBarError.self) {
                try await state.modeHandler.transition(state, on: action, with: nil)
            }
        }
    }

    // MARK: - SearchBarInViewModeHandler

    @MainActor
    @Test func viewModeStartSearchMovesToSearchMode() async throws {
        let state = SearchBarInViewMode<RecordingSearchBarStateContext>("overlay", "content")
        #expect(state.modeHandler is SearchBarInViewModeHandler<RecordingSearchBarStateContext>)
        #expect(state.showCancelButton == false)

        let next = try await state.modeHandler.transition(
            state,
            on: .startSearch("query"),
            with: nil
        )

        #expect(next is SearchBarInSearchMode<RecordingSearchBarStateContext>)
        #expect(next.query == "query")
        #expect(next.overlayContent == "overlay")
        #expect(next.searchBarContent == "content")
        #expect(next.showCancelButton)
    }

    @MainActor
    @Test func viewModeStartSearchWithNilQuery() async throws {
        let state = SearchBarInViewMode<RecordingSearchBarStateContext>()
        let next = try await state.modeHandler.transition(
            state,
            on: .startSearch(nil),
            with: nil
        )
        #expect(next is SearchBarInSearchMode<RecordingSearchBarStateContext>)
        #expect(next.query == nil)
    }

    @MainActor
    @Test func viewModeRejectsCancelSearch() async {
        let state = SearchBarInViewMode<RecordingSearchBarStateContext>()
        do {
            _ = try await state.modeHandler.transition(state, on: .cancelSearch, with: nil)
            Issue.record("Expected cannotCancelSearchWhenInViewMode")
        } catch let error as SearchBarError {
            guard case .cannotCancelSearchWhenInViewMode = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @MainActor
    @Test func viewModeUpdateViewMutatesContent() async throws {
        let state = SearchBarInViewMode<RecordingSearchBarStateContext>("old", "old-bar")
        let next = try await state.modeHandler.transition(
            state,
            on: .updateView("new-overlay", "new-bar"),
            with: nil
        )
        #expect(next === state)
        #expect(next.overlayContent == "new-overlay")
        #expect(next.searchBarContent == "new-bar")
        #expect(next.overlay == "new-overlay")
        #expect(next.content == "new-bar")
    }

    @MainActor
    @Test func viewModeClearViewReturnsEmptyViewMode() async throws {
        let state = SearchBarInViewMode<RecordingSearchBarStateContext>("overlay", "content")
        let next = try await state.modeHandler.transition(state, on: .clearView, with: nil)
        #expect(next is SearchBarInViewMode<RecordingSearchBarStateContext>)
        #expect(next.overlayContent == nil)
        #expect(next.searchBarContent == nil)
        #expect(next !== state)
    }

    @MainActor
    @Test func viewModeRejectsSelectSuggestion() async {
        let state = SearchBarInViewMode<RecordingSearchBarStateContext>()
        do {
            _ = try await state.modeHandler.transition(
                state,
                on: .selectSuggestion(.suggestion("x")),
                with: nil
            )
            Issue.record("Expected cannotSeeSuggestionsInViewMode")
        } catch let error as SearchBarError {
            guard case .cannotSeeSuggestionsInViewMode = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    // MARK: - SearchBarInSearchModeHandler

    @MainActor
    @Test func searchModeRejectsStartSearch() async {
        let state = SearchBarInSearchMode<RecordingSearchBarStateContext>(nil, nil, nil)
        #expect(state.modeHandler is SearchBarInSearchModeHandler<RecordingSearchBarStateContext>)
        #expect(state.showCancelButton)

        do {
            _ = try await state.modeHandler.transition(
                state,
                on: .startSearch("again"),
                with: nil
            )
            Issue.record("Expected alreadyInSearchMode")
        } catch let error as SearchBarError {
            guard case .alreadyInSearchMode = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @MainActor
    @Test func searchModeCancelReturnsToViewMode() async throws {
        let state = SearchBarInSearchMode<RecordingSearchBarStateContext>("q", "o", "c")
        let next = try await state.modeHandler.transition(
            state,
            on: .cancelSearch,
            with: nil
        )
        #expect(next is SearchBarInViewMode<RecordingSearchBarStateContext>)
        #expect(next.overlayContent == "o")
        #expect(next.searchBarContent == "c")
        #expect(next.query == nil)
        #expect(next.showCancelButton == false)
    }

    @MainActor
    @Test func searchModeUpdateViewMutatesContent() async throws {
        let state = SearchBarInSearchMode<RecordingSearchBarStateContext>("q", "o", "c")
        let next = try await state.modeHandler.transition(
            state,
            on: .updateView("overlay2", "bar2"),
            with: nil
        )
        #expect(next === state)
        #expect(next.overlayContent == "overlay2")
        #expect(next.searchBarContent == "bar2")
        #expect(next.query == "q")
    }

    @MainActor
    @Test func searchModeClearViewReturnsEmptyViewMode() async throws {
        let state = SearchBarInSearchMode<RecordingSearchBarStateContext>("q", "o", "c")
        let next = try await state.modeHandler.transition(state, on: .clearView, with: nil)
        #expect(next is SearchBarInViewMode<RecordingSearchBarStateContext>)
        #expect(next.overlayContent == nil)
        #expect(next.searchBarContent == nil)
    }

    @MainActor
    @Test func searchModeSelectSuggestionNotifiesContextAndReturnsViewMode() async throws {
        let context = RecordingSearchBarStateContext()
        let state = SearchBarInSearchMode<RecordingSearchBarStateContext>("q", "o", "c")
        let suggestion = SuggestionType.knownDomain("example.com")

        let next = try await state.modeHandler.transition(
            state,
            on: .selectSuggestion(suggestion),
            with: context
        )

        #expect(next is SearchBarInViewMode<RecordingSearchBarStateContext>)
        #expect(next.overlayContent == nil)
        #expect(next.searchBarContent == nil)
        #expect(context.selectedSuggestions == [suggestion])
    }

    @MainActor
    @Test func searchModeSelectSuggestionWithNilContextStillReturnsViewMode() async throws {
        let state = SearchBarInSearchMode<RecordingSearchBarStateContext>("q", "o", "c")
        let next = try await state.modeHandler.transition(
            state,
            on: .selectSuggestion(.suggestion("swift")),
            with: nil
        )
        #expect(next is SearchBarInViewMode<RecordingSearchBarStateContext>)
    }

    @MainActor
    @Test func searchModeSelectSuggestionPropagatesContextError() async {
        let context = RecordingSearchBarStateContext()
        context.errorToThrow = RecordingError.intentional
        let state = SearchBarInSearchMode<RecordingSearchBarStateContext>("q", nil, nil)

        await #expect(throws: RecordingError.self) {
            try await state.modeHandler.transition(
                state,
                on: .selectSuggestion(.suggestion("swift")),
                with: context
            )
        }
        #expect(context.selectedSuggestions.isEmpty)
    }

    // MARK: - SearchBarStateTransitioning

    @MainActor
    @Test func stateTransitioningDispatchesToModeHandler() async throws {
        let transitioning = SearchBarStateTransitioning<RecordingSearchBarStateContext>()
        let state = SearchBarInViewMode<RecordingSearchBarStateContext>("o", "c")
        let next = try await transitioning.transition(
            from: state,
            on: .startSearch("query"),
            with: nil
        )
        #expect(next is SearchBarInSearchMode<RecordingSearchBarStateContext>)
        #expect(next.query == "query")
    }

    @MainActor
    @Test func createInitialIsEmptyViewMode() {
        let initial = SearchBarState<RecordingSearchBarStateContext>.createInitial()
        #expect(initial is SearchBarInViewMode<RecordingSearchBarStateContext>)
        #expect(initial.overlay.isEmpty)
        #expect(initial.content.isEmpty)
        #expect(initial.showCancelButton == false)
    }
}
