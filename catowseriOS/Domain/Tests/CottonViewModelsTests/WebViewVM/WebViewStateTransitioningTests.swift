//
//  WebViewStateTransitioningTests.swift
//  CottonViewModelsTests
//

import Foundation
import Testing
import CottonBase
import CottonPlugins
import WebKit
@testable import CottonViewModels

@MainActor
private final class FakeWebViewStateContext: WebViewStateContext {
    var pluginsSource: any JSPluginsSource { fatalError("unused") }
    var isDohEnabledValue: Bool = false
    var isDohEnabled: Bool { get async { isDohEnabledValue } }

    func allowNativeAppRedirects() async -> Bool { true }
    func nativeApp(for host: CottonBase.Host) -> String? { nil }
    func resolveDomainName(_ originalURL: URL) async throws -> URL { originalURL }
    func remember(host: CottonBase.Host) async {}
    func replaceSelectedTab(with site: Site) async throws {}
    func enablePlugins(
        on subject: JavaScriptEvaluateble,
        context host: CottonBase.Host,
        jsEnabled: Bool
    ) {}
    func injectPlugins(
        _ program: any JSPluginsProgram,
        into configuration: WKWebViewConfiguration,
        context host: CottonBase.Host,
        canInject: Bool
    ) {}
    var webViewConfiguration: WKWebViewConfiguration { WKWebViewConfiguration() }
}

struct WebViewStateTransitioningTests {
    @MainActor
    @Test func loadSiteFromInitializedGoesToPendingPlugins() async throws {
        let settings = Site.Settings(
            isPrivate: false,
            blockPopups: true,
            isJSEnabled: false,
            canLoadPlugins: false
        )
        // swiftlint:disable:next force_try
        let domain = try! DomainName(input: "www.example.com")
        let urlInfo = URLInfo(
            scheme: .https,
            path: "foo",
            query: nil,
            domainName: domain,
            ipAddress: nil
        )
        let site = Site(
            urlInfo: urlInfo,
            settings: settings,
            faviconData: nil,
            searchSuggestion: nil,
            userSpecifiedTitle: nil
        )
        let strategy = WebViewStateTransitioning<FakeWebViewStateContext>()
        let next = try await strategy.transition(
            from: .initialized(site),
            on: .loadSite,
            with: nil
        )
        #expect(next == .pendingPlugins(urlInfo, settings))
    }

    @MainActor
    @Test func illegalActionThrowsAndLeavesStateUnchangedConceptually() async {
        let strategy = WebViewStateTransitioning<FakeWebViewStateContext>()
        let initial: WebViewModelState<FakeWebViewStateContext> = .pendingLoad
        await #expect(throws: WebViewModelState<FakeWebViewStateContext>.Error.self) {
            _ = try await strategy.transition(
                from: initial,
                on: .reload,
                with: nil
            )
        }
    }

    @MainActor
    @Test func resolveDomainNameFalseCreatesRequest() async throws {
        let settings = Site.Settings(
            isPrivate: false,
            blockPopups: true,
            isJSEnabled: false,
            canLoadPlugins: false
        )
        // swiftlint:disable:next force_try
        let domain = try! DomainName(input: "www.example.com")
        let urlInfo = URLInfo(
            scheme: .https,
            path: "foo",
            query: nil,
            domainName: domain,
            ipAddress: nil
        )
        let strategy = WebViewStateTransitioning<FakeWebViewStateContext>()
        let next = try await strategy.transition(
            from: .pendingDoHStatus(urlInfo, settings),
            on: .resolveDomainName(false),
            with: FakeWebViewStateContext()
        )
        #expect(next == .creatingRequest(urlInfo, settings))
    }
}
