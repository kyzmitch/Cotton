//
//  AllTabsStateTransitioningTests.swift
//  CottonViewModelsTests
//

import Testing
import CoreBrowser
@testable import CottonViewModels

@MainActor
private final class RecordingAllTabsContext: AllTabsStateContext {
    private(set) var addedTabs: [CoreBrowser.Tab] = []

    func handleTabAdd(_ tab: CoreBrowser.Tab) {
        addedTabs.append(tab)
    }
}

struct AllTabsStateTransitioningTests {
    @MainActor
    @Test func addTabInvokesContext() async throws {
        let context = RecordingAllTabsContext()
        let transitioning = AllTabsStateTransitioning<RecordingAllTabsContext>()
        let tab = CoreBrowser.Tab(contentType: .homepage)
        let next = try await transitioning.transition(
            from: .createInitial(),
            on: .addTab(tab),
            with: context
        )
        #expect(next == AllTabsState.createInitial())
        #expect(context.addedTabs == [tab])
    }
}
