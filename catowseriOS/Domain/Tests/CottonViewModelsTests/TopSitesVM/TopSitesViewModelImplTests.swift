//
//  TopSitesViewModelImplTests.swift
//  CottonViewModelsTests
//

import CoreBrowser
import CottonBase
import Testing
@testable import CottonViewModels

struct TopSitesViewModelImplTests {
    @MainActor
    @Test func initSeedsSitesIntoState() {
        let useCase = MockReplaceSelectedTabUseCase()
        let sites = [Self.makeSite(host: "www.cotton.app")]
        let vm = TopSitesViewModelImpl(sites, useCase)

        #expect(vm.state.sites == sites)
        #expect(vm.topSites == sites)
    }

    @MainActor
    @Test func sendActionReplaceSelectedInvokesUseCase() async throws {
        let useCase = MockReplaceSelectedTabUseCase()
        let site = Self.makeSite(host: "www.opennet.ru")
        let vm = TopSitesViewModelImpl([site], useCase)

        try await vm.sendAction(.replaceSelected(.site(site)))

        #expect(useCase.executeCalls == [.site(site)])
        #expect(vm.topSites == [site])
    }

    @MainActor
    @Test func replaceSelectedHelperPreservesSites() async throws {
        let useCase = MockReplaceSelectedTabUseCase()
        let site = Self.makeSite(host: "www.example.com")
        let vm = TopSitesViewModelImpl([site], useCase)

        // Fire-and-forget helper; await the same action path for assertion.
        try await vm.sendAction(.replaceSelected(.site(site)))

        #expect(vm.state.sites == [site])
        #expect(useCase.executeCalls.count == 1)
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
