//
//  TopSitesStateTransitioningTests.swift
//  CottonViewModelsTests
//

import CoreBrowser
import CottonBase
import Testing
@testable import CottonViewModels

@MainActor
private final class RecordingTopSitesContext: TopSitesStateContext {
    private(set) var replacedContents: [CoreBrowser.Tab.ContentType] = []

    func replaceSelectedTab(with content: CoreBrowser.Tab.ContentType) async {
        replacedContents.append(content)
    }
}

struct TopSitesStateTransitioningTests {
    @MainActor
    @Test func replaceSelectedInvokesContextAndKeepsSites() async throws {
        let context = RecordingTopSitesContext()
        let transitioning = TopSitesStateTransitioning<RecordingTopSitesContext>()
        let sites = [Self.makeSite(host: "www.example.com")]
        let initial = TopSitesViewState<RecordingTopSitesContext>(sites: sites)

        let next = try await transitioning.transition(
            from: initial,
            on: .replaceSelected(.site(sites[0])),
            with: context
        )

        #expect(next == initial)
        #expect(next.sites == sites)
        #expect(context.replacedContents == [.site(sites[0])])
    }

    @MainActor
    @Test func replaceSelectedWithNilContextLeavesStateUnchanged() async throws {
        let transitioning = TopSitesStateTransitioning<RecordingTopSitesContext>()
        let initial = TopSitesViewState<RecordingTopSitesContext>.createInitial()

        let next = try await transitioning.transition(
            from: initial,
            on: .replaceSelected(.topSites),
            with: nil
        )

        #expect(next == initial)
        #expect(next.sites.isEmpty)
    }

    @MainActor
    @Test func createInitialHasEmptySites() {
        let initial = TopSitesViewState<RecordingTopSitesContext>.createInitial()
        #expect(initial.sites.isEmpty)
    }

    private static func makeSite(host: String) -> Site {
        let settings = Site.Settings(
            isPrivate: false,
            blockPopups: true,
            isJSEnabled: true,
            canLoadPlugins: false
        )
        // swiftlint:disable:next force_try
        let domain = try! DomainName(input: host)
        let urlInfo = URLInfo(
            scheme: .https,
            path: "",
            query: nil,
            domainName: domain,
            ipAddress: nil
        )
        return Site(
            urlInfo: urlInfo,
            settings: settings,
            faviconData: nil,
            searchSuggestion: nil,
            userSpecifiedTitle: nil
        )
    }
}
