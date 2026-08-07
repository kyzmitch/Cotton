//
//  SearchBarViewModelImplTests.swift
//  CottonViewModelsTests
//

import Foundation
import Testing
import CoreBrowser
import CottonBase
@testable import CottonViewModels

private enum TestUseCaseError: Error {
    case createURLFailed
    case replaceTabFailed
}

@MainActor
private struct SearchBarVMFixture {
    let writeTabsUseCase = MockReplaceSelectedTabUseCase()
    let createSearchURLUseCase = MockCreateSearchURLUseCase()
    let appContext = MockSearchBarContext(
        blockPopups: true,
        isJSEnabled: false,
        webAutocompletionSource: .google
    )

    func makeViewModel() -> SearchBarViewModelImpl {
        SearchBarViewModelImpl(writeTabsUseCase, createSearchURLUseCase, appContext)
    }

    func enterSearchMode(_ viewModel: SearchBarViewModelImpl) async throws {
        try await viewModel.sendAction(.startSearch("query"))
        #expect(viewModel.state is SearchBarInSearchMode<SearchBarStateContextProxy>)
    }
}

struct SearchBarViewModelImplTests {

    // MARK: - Initialization & delegates

    @MainActor
    @Test func initialStateIsViewModeWithDelegates() {
        let fixture = SearchBarVMFixture()
        let viewModel = fixture.makeViewModel()
        #expect(viewModel.state is SearchBarInViewMode<SearchBarStateContextProxy>)
        #expect(viewModel.searchBarDelegate != nil)
        #expect(viewModel.searchSuggestionsDelegate != nil)
        #expect(viewModel.context != nil)
    }

    // MARK: - State transitions via sendAction

    @MainActor
    @Test func startSearchMovesToSearchMode() async throws {
        let fixture = SearchBarVMFixture()
        let viewModel = fixture.makeViewModel()
        try await viewModel.sendAction(.startSearch("cats"))
        #expect(viewModel.state is SearchBarInSearchMode<SearchBarStateContextProxy>)
        #expect(viewModel.state.query == "cats")
        #expect(viewModel.state.showCancelButton)
    }

    @MainActor
    @Test func cancelSearchReturnsToViewModePreservingContent() async throws {
        let fixture = SearchBarVMFixture()
        let viewModel = fixture.makeViewModel()
        try await viewModel.sendAction(.updateView("Title", "https://example.com"))
        try await viewModel.sendAction(.startSearch("cats"))
        try await viewModel.sendAction(.cancelSearch)

        #expect(viewModel.state is SearchBarInViewMode<SearchBarStateContextProxy>)
        #expect(viewModel.state.overlayContent == "Title")
        #expect(viewModel.state.searchBarContent == "https://example.com")
        #expect(viewModel.state.showCancelButton == false)
    }

    @MainActor
    @Test func updateViewAndClearView() async throws {
        let fixture = SearchBarVMFixture()
        let viewModel = fixture.makeViewModel()
        try await viewModel.sendAction(.updateView("Overlay", "bar-content"))
        #expect(viewModel.state.overlayContent == "Overlay")
        #expect(viewModel.state.searchBarContent == "bar-content")

        try await viewModel.sendAction(.clearView)
        #expect(viewModel.state is SearchBarInViewMode<SearchBarStateContextProxy>)
        #expect(viewModel.state.overlayContent == nil)
        #expect(viewModel.state.searchBarContent == nil)
    }

    @MainActor
    @Test func cancelSearchInViewModeFailsWithoutChangingState() async {
        let fixture = SearchBarVMFixture()
        let viewModel = fixture.makeViewModel()
        await #expect(throws: SearchBarError.self) {
            try await viewModel.sendAction(.cancelSearch)
        }
        #expect(viewModel.state is SearchBarInViewMode<SearchBarStateContextProxy>)
    }

    // MARK: - Suggestion selection → replace selected tab

    @MainActor
    @Test func selectLooksLikeURLReplacesTab() async throws {
        let fixture = SearchBarVMFixture()
        let viewModel = fixture.makeViewModel()
        try await fixture.enterSearchMode(viewModel)

        try await viewModel.sendAction(.selectSuggestion(.looksLikeURL("https://www.example.com/path")))

        #expect(viewModel.state is SearchBarInViewMode<SearchBarStateContextProxy>)
        #expect(fixture.writeTabsUseCase.executeCalls.count == 1)
        guard case .site(let site) = fixture.writeTabsUseCase.executeCalls.first else {
            Issue.record("Expected site content type")
            return
        }
        #expect(site.urlInfo.platformURL.absoluteString == "https://www.example.com/path")
        #expect(site.searchSuggestion == nil)
        #expect(site.settings.isJSEnabled == false)
        #expect(site.settings.blockPopups == true)
        #expect(fixture.createSearchURLUseCase.executeCalls.isEmpty)
    }

    @MainActor
    @Test func selectKnownDomainReplacesTabWithHTTPSURL() async throws {
        let fixture = SearchBarVMFixture()
        let viewModel = fixture.makeViewModel()
        try await fixture.enterSearchMode(viewModel)

        try await viewModel.sendAction(.selectSuggestion(.knownDomain("www.example.com")))

        #expect(fixture.writeTabsUseCase.executeCalls.count == 1)
        guard case .site(let site) = fixture.writeTabsUseCase.executeCalls.first else {
            Issue.record("Expected site content type")
            return
        }
        #expect(site.urlInfo.platformURL.host == "www.example.com")
        #expect(site.urlInfo.platformURL.scheme == "https")
        #expect(site.searchSuggestion == nil)
        #expect(fixture.createSearchURLUseCase.executeCalls.isEmpty)
    }

    @MainActor
    @Test func selectSuggestionCreatesSearchURLThenReplacesTab() async throws {
        let fixture = SearchBarVMFixture()
        guard let expectedURL = URL(string: "https://www.google.com/search?q=swift") else {
            return
        }
        fixture.createSearchURLUseCase.executeHandler = { input in
            #expect(input.source == .google)
            #expect(input.suggestion == "swift")
            return expectedURL
        }

        let viewModel = fixture.makeViewModel()
        try await fixture.enterSearchMode(viewModel)
        try await viewModel.sendAction(.selectSuggestion(.suggestion("swift")))

        #expect(fixture.createSearchURLUseCase.executeCalls.count == 1)
        #expect(fixture.writeTabsUseCase.executeCalls.count == 1)
        guard case .site(let site) = fixture.writeTabsUseCase.executeCalls.first else {
            Issue.record("Expected site content type")
            return
        }
        #expect(site.urlInfo.platformURL == expectedURL)
        #expect(site.searchSuggestion == "swift")
        #expect(viewModel.state is SearchBarInViewMode<SearchBarStateContextProxy>)
    }

    // MARK: - Error paths

    @MainActor
    @Test func selectInvalidLooksLikeURLThrows() async throws {
        let fixture = SearchBarVMFixture()
        let viewModel = fixture.makeViewModel()
        try await fixture.enterSearchMode(viewModel)

        do {
            try await viewModel.sendAction(.selectSuggestion(.looksLikeURL("")))
            Issue.record("Expected looksLikeUrlButNotExactly")
        } catch let error as SearchBarError {
            guard case .looksLikeUrlButNotExactly("") = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }

        #expect(fixture.writeTabsUseCase.executeCalls.isEmpty)
        #expect(viewModel.state is SearchBarInSearchMode<SearchBarStateContextProxy>)
    }

    @MainActor
    @Test func selectLooksLikeURLWithIPHostFailsToInitSite() async throws {
        let fixture = SearchBarVMFixture()
        let viewModel = fixture.makeViewModel()
        try await fixture.enterSearchMode(viewModel)

        do {
            try await viewModel.sendAction(
                .selectSuggestion(.looksLikeURL("http://127.0.0.1/"))
            )
            Issue.record("Expected failToInitNewSiteValue")
        } catch let error as SearchBarError {
            guard case .failToInitNewSiteValue = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }

        #expect(fixture.writeTabsUseCase.executeCalls.isEmpty)
    }

    @MainActor
    @Test func createSearchURLFailurePropagatesAndKeepsSearchMode() async throws {
        let fixture = SearchBarVMFixture()
        fixture.createSearchURLUseCase.executeHandler = { _ in
            throw TestUseCaseError.createURLFailed
        }

        let viewModel = fixture.makeViewModel()
        try await fixture.enterSearchMode(viewModel)

        await #expect(throws: TestUseCaseError.self) {
            try await viewModel.sendAction(.selectSuggestion(.suggestion("swift")))
        }
        #expect(fixture.writeTabsUseCase.executeCalls.isEmpty)
        #expect(viewModel.state is SearchBarInSearchMode<SearchBarStateContextProxy>)
    }

    @MainActor
    @Test func replaceTabFailurePropagatesAndKeepsSearchMode() async throws {
        let fixture = SearchBarVMFixture()
        fixture.writeTabsUseCase.executeHandler = { _ in
            throw TestUseCaseError.replaceTabFailed
        }

        let viewModel = fixture.makeViewModel()
        try await fixture.enterSearchMode(viewModel)

        await #expect(throws: TestUseCaseError.self) {
            try await viewModel.sendAction(
                .selectSuggestion(.looksLikeURL("https://www.example.com"))
            )
        }
        #expect(fixture.writeTabsUseCase.executeCalls.count == 1)
        #expect(viewModel.state is SearchBarInSearchMode<SearchBarStateContextProxy>)
    }

    @MainActor
    @Test func usesAppContextAutocompletionSource() async throws {
        let fixture = SearchBarVMFixture()
        fixture.appContext.webAutocompletionSource = .duckduckgo
        guard let expectedURL = URL(string: "https://duckduckgo.com/?q=cotton") else {
            return
        }
        fixture.createSearchURLUseCase.executeHandler = { input in
            #expect(input.source == .duckduckgo)
            return expectedURL
        }

        let viewModel = fixture.makeViewModel()
        try await fixture.enterSearchMode(viewModel)
        try await viewModel.sendAction(.selectSuggestion(.suggestion("cotton")))

        #expect(fixture.createSearchURLUseCase.executeCalls.first?.source == .duckduckgo)
    }
}
