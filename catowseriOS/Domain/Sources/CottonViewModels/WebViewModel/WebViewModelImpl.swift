//
//  WebViewModelImpl.swift
//  catowser
//
//  Created by Andrei Ermoshin on 7/26/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation
import CottonBase
import CoreBrowser
import CottonPlugins
import CottonUseCases
import CottonNetworking
import Combine
import WebKit
import FeatureFlagsKit
import ViewModelKit

/**
    See `decidePolicy` method below

 To avoid errors, when DoH is enabled, many sites
 uses additional requests but with different hosts
 it could be analytics or something else, some dependency.
 Turns out that implementation of DoH for these hosts isn't obvious, but
 there is one approach: we can allow side request to be made without DoH,
 because they're not initiated by browser user and can't describe
 what user likes or wanted to find on internet.

 So that, as initial solution will try to not do DoH operations for
 navigation requests related to analytics or any other not user initiated requests.
 This is also actually solves issue with site loading with DoH enabled,
 because analytics related requests are mandatory for sites for some reason
 and at least on iPad I see weird behaviour if analytics were loaded by IP address.

 only cancel immediate navigation with following conditions:
 - DoH is enabled
 - requested URL doesn't contain ip address instead of host
 (this means that DoH request MUST be performed if it's enabled)
 - pending navigation request is related to initial host or similar host used by user (search bar url)
 */

@MainActor final class WebViewModelImpl: WebViewModelBase, WebViewModel {
    /// Domain name resolver with specific strategy
    private let resolveDnsUseCase: any ResolveDNSUseCase

    /// Configuration should be transferred from `Site`
    public var configuration: WKWebViewConfiguration {
        settings.webViewConfig
    }
    /// web view model context to access plugins and other dependencies
    let appContext: any WebViewContext

    lazy var dnsRequestTaskHandler: Task<URL, Error>? = nil

    public var host: CottonBase.Host { state.host }

    public var currentURL: URL? { state.platformURL }

    public var settings: Site.Settings { state.settings }

    public var urlInfo: URLInfo { state.urlInfo }

    public var isResetable: Bool { state.isResetable }

    public var nativeAppDomainNameString: String? {
        appContext.nativeApp(for: host)
    }

    private let selectTabUseCase: any SelectedTabUseCase

    private let replaceTabUseCase: any ReplaceSelectedTabUseCase

    public weak var siteNavigation: SiteExternalNavigationDelegate?

    private lazy var proxy = WebViewStateContextProxy(subject: self)

    /// Guards re-entrant pipeline continuations from nested `sendAction`.
    private var isContinuingPipeline = false

    /**
     Constructs web view model.

     For SwiftUI mode it is the same instance all the time, because web view model depends on async use cases
     and the init is async, that is why you can't use it in SwiftUI because it can't wait asynhroniously and
     need to build the view right away. That is why for SwiftUI mode we have to pass specific Site after view was built.

     @param context A context for a view model
     @param resolveDnsUseCase A use case dependency to check how to load web page links
     @param selectTabUseCase A use case dependency to select specific tab content
     @param replaceTabUseCase A use case dependency to replace tab's content
     @param siteNavigation Delegate site navigation handling (e.g. forward/backward button states)
     @param site Can be nil when you are using just one same web view model because can't create new one every time in SwiftUI mode
     */
    init(
        _ context: any WebViewContext,
        _ resolveDnsUseCase: any ResolveDNSUseCase,
        _ selectTabUseCase: any SelectedTabUseCase,
        _ replaceTabUseCase: any ReplaceSelectedTabUseCase,
        _ siteNavigation: SiteExternalNavigationDelegate?,
        _ site: Site? = nil
    ) {
        self.resolveDnsUseCase = resolveDnsUseCase
        self.appContext = context
        self.selectTabUseCase = selectTabUseCase
        self.replaceTabUseCase = replaceTabUseCase
        self.siteNavigation = siteNavigation
        super.init(transitioning: WebViewStateTransitioning())
        if let site {
            // Site-bearing init: replace createInitial `.pendingLoad` without a fake transition.
            state = .initialized(site)
        }
    }

    public override var context: Context? {
        proxy
    }

    public override func sendAction(_ action: Action) async throws {
        try await super.sendAction(action)
        guard !isContinuingPipeline else { return }
        try await runPipeline()
    }

    public func decidePolicy(
        _ navigationAction: NavigationActionable,
        _ decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) async {
        let policy = await decidePolicy(navigationAction)
        decisionHandler(policy)
    }

    public func decidePolicy(
        _ navigationAction: NavigationActionable
    ) async -> WKNavigationActionPolicy {
        guard navigationAction.navigationType.needsHandling else {
            print("navigationType: ignored '\(navigationAction.navigationType)'")
            return .allow
        }
        print("navigationType: need to handle '\(navigationAction.navigationType)'")
        guard let url = navigationAction.request.url else {
            return .allow
        }
        if shouldOpenInExternalApp(url) {
            return .cancel
        }
        let allowRedirect = await appContext.allowNativeAppRedirects()
        if !allowRedirect, let policy = isNativeAppRedirectNeeded(url) {
            return policy
        }
        guard let scheme = url.scheme else {
            return .allow
        }

        switch scheme {
        case .http, .https:
            let currentURLinfo = state.urlInfo
            if currentURLinfo.platformURL == url ||
                (currentURLinfo.ipAddressString != nil && currentURLinfo.urlWithResolvedDomainName == url) {
                return .allow
            }
            do {
                try await sendAction(.loadNextLink(url))
                return .cancel
            } catch {
                print("Fail to load next URL due to error: \(error.localizedDescription)")
            }
        case .about:
            return .allow
        default:
            return .cancel
        }
        return .allow
    }

    public func shouldOpenInExternalApp(_ url: URL) -> Bool {
        isSystemAppRedirectNeeded(url) != nil
    }

    public func updateTabPreview(_ screenshot: Data?) async {
        do {
            try await selectTabUseCase.execute(input: screenshot)
        } catch {
            print("Fail to update tab preview: \(error)")
        }
    }
}

// MARK: - Pipeline continuation (former onStateChange)

private extension WebViewModelImpl {
    /// After each user-facing transition, run side effects and follow-up actions.
    /// Uses `super.sendAction` inside the loop so intermediate states publish without re-entrancy.
    func runPipeline() async throws {
        isContinuingPipeline = true
        defer { isContinuingPipeline = false }
        while try await stepPipelineOnce() {}
    }

    /// Returns `true` when another pipeline step may be needed.
    // swiftlint:disable:next cyclomatic_complexity
    func stepPipelineOnce() async throws -> Bool {
        switch state {
        case .pendingLoad, .initialized, .waitingForNavigation, .viewing:
            return false
        case .pendingPlugins:
            let pluginsSource = settings.canLoadPlugins ? appContext.pluginsSource : nil
            try await super.sendAction(.injectPlugins(pluginsSource?.jsProgram))
            return true
        case .injectingPlugins(let pluginsProgram, let urlData, let settings):
            let canInject = settings.canLoadPlugins
            injectPlugins(
                pluginsProgram,
                into: configuration,
                context: urlData.host(),
                canInject: canInject
            )
            try await super.sendAction(.fetchDoHStatus)
            return true
        case .pendingDoHStatus:
            let enabled = await appContext.isDohEnabled
            try await super.sendAction(.resolveDomainName(enabled))
            return true
        case .checkingDNResolveSupport(let urlData, _):
            let dohWillWork = urlData.host().isDoHSupported
            let domainNameAlreadyResolved = urlData.ipAddressString != nil
            try await super.sendAction(
                .checkDNResolvingSupport(dohWillWork && !domainNameAlreadyResolved)
            )
            return true
        case .resolvingDN(let urlData, _):
            await resolveDomainName(urlData)
            // DNS applies creatingRequest without loadWebView (legacy DoH stop).
            return false
        case .creatingRequest:
            try await super.sendAction(.loadWebView)
            return true
        case .updatingWebView:
            // View loads via `statePublisher` observation.
            return false
        case .finishingLoading(let settings, let newURL, let subject, let enable, let urlData):
            // swiftlint:disable:next force_unwrapping
            let updatedInfo = urlData.withSimilar(newURL)!
            let site = Site.create(urlInfo: updatedInfo, settings: settings)
            let host = updatedInfo.host()
            await InMemoryDomainSearchProvider.shared.remember(host: host)
            enablePlugins(on: subject, context: host, jsEnabled: enable)
            try await replaceTabUseCase.execute(input: .site(site))
            try await super.sendAction(.startView(updatedInfo))
            return true
        case .updatingJS(let settings, let subject, let urlInfo):
            enablePlugins(on: subject, context: urlInfo.host(), jsEnabled: settings.isJSEnabled)
            // View recreates / reattaches / loads via `statePublisher` observation.
            return false
        }
    }

    func resolveDomainName(_ urlData: URLInfo) async {
        guard urlData.ipAddressString == nil else {
            // Preserve old DoH behavior: land on creatingRequest without loadWebView.
            await applyCreateRequestWithoutPipeline(urlData.ipAddressString)
            return
        }
        dnsRequestTaskHandler?.cancel()
        await aaResolveDomainName(urlData.platformURL)
    }

    @available(iOS 15.0, *)
    func aaResolveDomainName(_ originalURL: URL) async {
        let taskHandler = Task.detached(priority: .userInitiated) { [weak self] () -> URL in
            guard let self = self else {
                throw AppError.zombieSelf
            }
            return try await self.resolveDnsUseCase.execute(input: originalURL)
        }
        dnsRequestTaskHandler = taskHandler
        do {
            let finalURL = try await taskHandler.value
            await applyCreateRequestWithoutPipeline(finalURL.host)
        } catch {
            print("Fail to resolve domain name: \(error.localizedDescription)")
            await applyCreateRequestWithoutPipeline(originalURL.host)
        }
    }

    /// Applies `.createRequestAnyway` without running the creatingRequest → loadWebView pipeline
    /// (matches pre-migration DoH path that set state without `onStateChange`).
    func applyCreateRequestWithoutPipeline(_ ipAddress: String?) async {
        do {
            // `super.sendAction` avoids `runPipeline` (caller already inside pipeline or wants a stop).
            try await super.sendAction(.createRequestAnyway(ipAddress))
        } catch {
            assertionFailure("Unexpected VM state when trying to `createRequestAnyway`")
        }
    }

    func isNativeAppRedirectNeeded(_ url: URL) -> WKNavigationActionPolicy? {
        guard let newHost = url.kitHost, appContext.nativeApp(for: newHost) != nil else {
            return nil
        }
        let ignoreAppRawValue = WKNavigationActionPolicy.allow.rawValue + 2
        guard WKNavigationActionPolicy(rawValue: ignoreAppRawValue) != nil else {
            return nil
        }
        // swiftlint:disable:next force_unwrapping
        return WKNavigationActionPolicy(rawValue: ignoreAppRawValue)!
    }

    func isSystemAppRedirectNeeded(_ url: URL) -> WKNavigationActionPolicy? {
        if let scheme = url.scheme {
            switch scheme {
            case .tel, .facetime, .facetimeAudio, .mailto:
                return WKNavigationActionPolicy.cancel
            default:
                break
            }
        }

        if url.isAppleMapsURL || url.isStoreURL {
            return WKNavigationActionPolicy.cancel
        }
        return nil
    }
}

// MARK: - WebViewStateContext

extension WebViewModelImpl: WebViewStateContext {
    public var pluginsSource: any JSPluginsSource { appContext.pluginsSource }

    public var isDohEnabled: Bool {
        get async { await appContext.isDohEnabled }
    }

    public func allowNativeAppRedirects() async -> Bool {
        await appContext.allowNativeAppRedirects()
    }

    public func nativeApp(for host: CottonBase.Host) -> String? {
        appContext.nativeApp(for: host)
    }

    public func resolveDomainName(_ originalURL: URL) async throws -> URL {
        try await resolveDnsUseCase.execute(input: originalURL)
    }

    public func remember(host: CottonBase.Host) async {
        await InMemoryDomainSearchProvider.shared.remember(host: host)
    }

    public func replaceSelectedTab(with site: Site) async throws {
        try await replaceTabUseCase.execute(input: .site(site))
    }

    public func enablePlugins(
        on subject: JavaScriptEvaluateble,
        context host: CottonBase.Host,
        jsEnabled: Bool
    ) {
        appContext.pluginsSource.jsProgram.enable(on: subject, context: host, jsEnabled: jsEnabled)
    }

    public func injectPlugins(
        _ program: any JSPluginsProgram,
        into configuration: WKWebViewConfiguration,
        context host: CottonBase.Host,
        canInject: Bool
    ) {
        program.inject(
            to: configuration.userContentController,
            context: host,
            canInject: canInject
        )
    }

    public var webViewConfiguration: WKWebViewConfiguration {
        configuration
    }
}

private extension String {
    static let tel = "tel"
    static let facetime = "facetime"
    static let facetimeAudio = "facetime-audio"
    static let mailto = "mailto"
    static let http = "http"
    static let https = "https"
    static let about = "about"
}

extension WKNavigationType {
    /// Tells if specific navigation need to be handled specifically
    /// E.g. back and forward navigations should be bypassed
    /// because anyway they're handled by finishLoading.
    /// Link activation navigations need to be handled to remeber new URL.
    /// Initial navigation during init has `other` type, it can be ignored as well.
    var needsHandling: Bool {
        switch self {
        case .linkActivated:
            return true
        case .formSubmitted:
            return false
        case .backForward:
            return false
        case .reload:
            return false
        case .formResubmitted:
            return false
        case .other:
            return false
        @unknown default:
            return false
        }
    }
}

extension Site {
    static func create(urlInfo: URLInfo, settings: Settings) -> Site {
        let site = Site(
            urlInfo: urlInfo,
            settings: settings,
            faviconData: nil,
            searchSuggestion: nil,
            userSpecifiedTitle: nil
        )
        return site
    }
}
