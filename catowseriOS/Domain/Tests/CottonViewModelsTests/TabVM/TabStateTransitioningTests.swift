//
//  TabStateTransitioningTests.swift
//  CottonViewModelsTests
//

import Foundation
import Testing
@testable import CottonViewModels

@MainActor
private final class FakeTabStateContext: TabStateContext {
    var tabTitle: String = "Example"
    var selected: Bool = false
    var favicon: ImageSource?
    var closeCallCount = 0
    var activateCallCount = 0
    var selectionError: Error?

    func isTabSelected() async throws -> Bool {
        if let selectionError {
            throw selectionError
        }
        return selected
    }

    func loadFavicon() async -> ImageSource? {
        favicon
    }

    func closeTab() async {
        closeCallCount += 1
    }

    func activateTab() async {
        activateCallCount += 1
    }
}

private struct SelectionFailure: Error {}

struct TabStateTransitioningTests {
    @MainActor
    @Test func loadReturnsSelectedStateWithFavicon() async throws {
        let context = FakeTabStateContext()
        context.selected = true
        context.tabTitle = "Cotton"
        context.favicon = .url(URL(string: "https://example.com/favicon.ico")!)
        let strategy = TabStateTransitioning<FakeTabStateContext>()

        let next = try await strategy.transition(
            from: .deSelected("", nil),
            on: .load,
            with: context
        )

        #expect(next.isSelected)
        #expect(next.title == "Cotton")
        #expect(next.favicon == context.favicon)
    }

    @MainActor
    @Test func loadReturnsDeselectedState() async throws {
        let context = FakeTabStateContext()
        context.selected = false
        context.tabTitle = "Other"
        let strategy = TabStateTransitioning<FakeTabStateContext>()

        let next = try await strategy.transition(
            from: .deSelected("", nil),
            on: .load,
            with: context
        )

        #expect(!next.isSelected)
        #expect(next.title == "Other")
        #expect(next.favicon == nil)
    }

    @MainActor
    @Test func applySelectionFlipsChromeWithoutChangingTitleOrFavicon() async throws {
        let context = FakeTabStateContext()
        let strategy = TabStateTransitioning<FakeTabStateContext>()
        let favicon = ImageSource.url(URL(string: "https://example.com/f.png")!)
        let initial = TabViewState<FakeTabStateContext>.deSelected("Title", favicon)

        let next = try await strategy.transition(
            from: initial,
            on: .applySelection(isSelected: true),
            with: context
        )

        #expect(next.isSelected)
        #expect(next.title == "Title")
        #expect(next.favicon == favicon)
    }

    @MainActor
    @Test func applyReplaceUpdatesTitleAndFavicon() async throws {
        let context = FakeTabStateContext()
        let strategy = TabStateTransitioning<FakeTabStateContext>()
        let initial = TabViewState<FakeTabStateContext>.selected("Old", nil)
        let favicon = ImageSource.url(URL(string: "https://example.com/new.png")!)

        let next = try await strategy.transition(
            from: initial,
            on: .applyReplace(title: "New", favicon: favicon),
            with: context
        )

        #expect(next.isSelected)
        #expect(next.title == "New")
        #expect(next.favicon == favicon)
    }

    @MainActor
    @Test func closeInvokesContextAndPreservesState() async throws {
        let context = FakeTabStateContext()
        let strategy = TabStateTransitioning<FakeTabStateContext>()
        let initial = TabViewState<FakeTabStateContext>.selected("Keep", nil)

        let next = try await strategy.transition(
            from: initial,
            on: .close,
            with: context
        )

        #expect(context.closeCallCount == 1)
        #expect(next == initial)
    }

    @MainActor
    @Test func activateInvokesContextAndPreservesState() async throws {
        let context = FakeTabStateContext()
        let strategy = TabStateTransitioning<FakeTabStateContext>()
        let initial = TabViewState<FakeTabStateContext>.deSelected("Keep", nil)

        let next = try await strategy.transition(
            from: initial,
            on: .activate,
            with: context
        )

        #expect(context.activateCallCount == 1)
        #expect(next == initial)
    }

    @MainActor
    @Test func missingContextThrows() async {
        let strategy = TabStateTransitioning<FakeTabStateContext>()
        let initial = TabViewState<FakeTabStateContext>.deSelected("", nil)

        await #expect(throws: TabViewState<FakeTabStateContext>.Error.self) {
            _ = try await strategy.transition(
                from: initial,
                on: .load,
                with: nil
            )
        }
    }

    @MainActor
    @Test func loadPropagatesSelectionErrorWithoutChangingCallerState() async {
        let context = FakeTabStateContext()
        context.selectionError = SelectionFailure()
        let strategy = TabStateTransitioning<FakeTabStateContext>()
        let initial = TabViewState<FakeTabStateContext>.deSelected("Same", nil)

        await #expect(throws: SelectionFailure.self) {
            _ = try await strategy.transition(
                from: initial,
                on: .load,
                with: context
            )
        }
    }
}
