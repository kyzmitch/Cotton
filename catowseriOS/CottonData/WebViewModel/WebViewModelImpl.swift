//
//  WebViewModelImpl.swift
//  catowser
//
//  Created by Andrei Ermoshin on 7/26/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import CottonBase
import CoreBrowser
import CottonPlugins
import BrowserNetworking
import ReactiveSwift
import Combine
import WebKit
import FeaturesFlagsKit

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

public final class WebViewModelImpl<Strategy>: WebViewModel where Strategy: DNSResolvingStrategy {
    /// Domain name resolver with specific strategy
    let dnsResolver: DNSResolver<Strategy>
    
    /// view model state (not private for unit tests only)
    var state: WebViewModelState {
        didSet {
            // TODO: Task doesn't work in didSet!
            Task {
                do {
                    try await onStateChange(state)
                } catch {
                    print("Wrong state: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// reactive state property
    public var rxWebPageState: MutableProperty<WebPageLoadingAction> = .init(.recreateView(false))
    /// Can be replaced with @Published
    public var combineWebPageState: CurrentValueSubject<WebPageLoadingAction, Never> = .init(.recreateView(false))
    /// wrapped value for Published
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    @Published public var webPageState: WebPageLoadingAction = .recreateView(false)
    /// Combine publisher of public view state (next action)
    public var webPageStatePublisher: Published<WebPageLoadingAction>.Publisher { $webPageState }
    
    /// Configuration should be transferred from `Site`
    public var configuration: WKWebViewConfiguration {
        settings.webViewConfig
    }
    /// web view model context to access plugins and other dependencies
    let context: any WebViewContext
    
    private var dnsRequestSubsrciption: Disposable?
    private lazy var dnsRequestCancellable: AnyCancellable? = nil
    lazy var dnsRequestTaskHandler: Task<URL, Error>? = nil
    
    public var host: CottonBase.Host { state.host }
    
    public var currentURL: URL? { state.platformURL }
    
    public var settings: Site.Settings { state.settings }
    
    public var urlInfo: URLInfo { state.urlInfo }
    
    public var isResetable: Bool { state.isResetable }
    
    public var nativeAppDomainNameString: String? {
        context.nativeApp(for: host)
    }
    
    /**
     Constructs web view model
     */
    public init(_ strategy: Strategy, _ site: Site, _ context: any WebViewContext) {
        dnsResolver = .init(strategy)
        state = .initialized(site)
        self.context = context
    }
    
    deinit {
        dnsRequestSubsrciption?.dispose()
        
        /**
        
         Can't do `dnsRequestCancellable?.cancel()` on main actor because of next:
         
         In a class annotated with a global actor, deinit isn’t isolated to an actor.
         It can’t be because the last reference to the actor could go out of scope on any thread/task.
         https://forums.swift.org/t/deinit-and-mainactor/50132/2
         
         A deinit cannot have a global actor attribute and is never a target for propagation.
         https://github.com/apple/swift-evolution/blob/main/proposals/0316-global-actors.md
         */
    }
    
    public func load() {
        do {
            // Have to ask to attach view observers here
            // because it is not really possible to do that
            // later only because `loadSite` is used
            // in other method in addition
            updateLoadingState(.reattachViewObservers)
            state = try state.transition(on: .loadSite)
        } catch {
            print("Wrong state on load action: " + error.localizedDescription)
        }
    }
    
    public func reset(_ site: Site) {
        do {
            // - Now state is set to `initialized` and can send `loadSite` action
            // - Have to delete old web view to clean web view navigation
            updateLoadingState(.recreateView(true))
            updateLoadingState(.reattachViewObservers)
            state = try state.transition(on: .resetToSite(site))
            state = try state.transition(on: .loadSite)
        } catch {
            print("Wrong state on reset to site action: " + error.localizedDescription)
        }
    }
    
    public func reload() {
        do {
            state = try state.transition(on: .reload)
        } catch {
            print("Wrong state on re-load action: " + error.localizedDescription)
        }
    }
    
    public func goBack() {
        do {
            state = try state.transition(on: .goBack)
        } catch {
            print("Wrong state on go Back action: " + error.localizedDescription)
        }
    }
    
    public func goForward() {
        do {
            state = try state.transition(on: .goForward)
        } catch {
            print("Wrong state on go Forward action: " + error.localizedDescription)
        }
    }
    
    public func finishLoading(_ newURL: URL, _ subject: JavaScriptEvaluateble) {
        /**
         you must inject/re-enable plugins even if web view loaded page from same Host
         and even if ip address is used instead of domain name.
         No need to care about value from `context.isJavaScriptEnabled()`
         Maybe it is not needed at all.
         */
        let jsEnabled = settings.isJSEnabled
        do {
            // url can be different from initial at least during navigation back and forward actions
            // so that, it has to be passed to update current url
            state = try state.transition(on: .finishLoading(newURL, subject, jsEnabled))
        } catch {
            print("\(#function) - failed to replace current tab: " + error.localizedDescription)
        }
    }
    
    public func decidePolicy(_ navigationAction: NavigationActionable,
                             _ decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard navigationAction.navigationType.needsHandling else {
            print("navigationType: ignored '\(navigationAction.navigationType)'")
            decisionHandler(.allow)
            return
        }
        print("navigationType: need to handle '\(navigationAction.navigationType)'")
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        if let policy = isSystemAppRedirectNeeded(url) {
            updateLoadingState(.openApp(url))
            decisionHandler(policy)
            return
        }
        Task {
            let allowRedirect = await context.allowNativeAppRedirects()
            if !allowRedirect, let policy = isNativeAppRedirectNeeded(url) {
                decisionHandler(policy)
                return
            }
            guard let scheme = url.scheme else {
                decisionHandler(.allow)
                return
            }
            
            switch scheme {
            case .http, .https:
                let currentURLinfo = state.urlInfo
                if currentURLinfo.platformURL == url ||
                  (currentURLinfo.ipAddressString != nil && currentURLinfo.urlWithResolvedDomainName == url) {
                    decisionHandler(.allow)
                    // No need to change vm state
                    // because it is the same URL which was provided
                    // in `.load` or `.loadNextLink`
                    return
                }
                do {
                    // Cancelling navigation because it is a different URL.
                    // Need to handle DoH, plugins and vm state.
                    // It also applies for go back and forward navigation actions.
                    decisionHandler(.cancel)
                    state = try state.transition(on: .loadNextLink(url))
                } catch {
                    print("Fail to load next URL due to error: \(error.localizedDescription)")
                }
            case .about:
                decisionHandler(.allow)
            default:
                decisionHandler(.cancel)
            }
        }
    }
    
    public func setJavaScript(_ subject: JavaScriptEvaluateble, _ enabled: Bool) {
        do {
            state = try state.transition(on: .changeJavaScript(subject, enabled))
        } catch {
            print("Wrong state on JS change action: " + error.localizedDescription)
        }
    }
    
    public func setDoH(_ enabled: Bool) {
        do {
            state = try state.transition(on: .changeDoH(enabled))
        } catch {
            print("Wrong state on DoH change action: " + error.localizedDescription)
        }
    }
}

private extension WebViewModelImpl {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func onStateChange(_ nextState: WebViewModelState) async throws {
        switch nextState {
        case .initialized:
            // No need to call `recreateView` because it is an initial state
            // Also, `reattachViewObservers` will be called automatically
            // before `loadSite` action
            break
        case .pendingPlugins:
            let pluginsProgram: (any JSPluginsProgram)? = settings.canLoadPlugins ? context.pluginsProgram : nil
            state = try state.transition(on: .injectPlugins(pluginsProgram))
        case .injectingPlugins(let pluginsProgram, let urlData, let settings):
            let canInject = settings.canLoadPlugins
            pluginsProgram.inject(to: configuration.userContentController,
                                  context: urlData.host(),
                                  canInject: canInject)
            state = try state.transition(on: .fetchDoHStatus)
        case .pendingDoHStatus:
            let enabled = await context.isDohEnabled()
            state = try state.transition(on: .resolveDomainName(enabled))
        case .checkingDNResolveSupport(let urlData, _):
            let dohWillWork = urlData.host().isDoHSupported
            // somehow url from site already or from next page request
            // contained ip address
            let domainNameAlreadyResolved = urlData.ipAddressString != nil
            state = try state.transition(on: .checkDNResolvingSupport(dohWillWork && !domainNameAlreadyResolved))
        case .resolvingDN(let urlData, _):
            resolveDomainName(urlData)
        case .creatingRequest:
            state = try state.transition(on: .loadWebView)
        case .updatingWebView(_, let urlInfo):
            // Not storing DoH state in vm state, can fetch it from context
            let useIPaddress = await context.isDohEnabled()
            updateLoadingState(.load(urlInfo.urlRequest(useIPaddress)))
        case .waitingForNavigation:
            break
        case .finishingLoading(let settings, let newURL, let subject, let enable, let urlData):
            // swiftlint:disable:next force_unwrapping
            let updatedInfo = urlData.withSimilar(newURL)!
            let site = Site.create(urlInfo: updatedInfo, settings: settings)
            let host = updatedInfo.host()
            await InMemoryDomainSearchProvider.shared.remember(host: host)
            context.pluginsProgram.enable(on: subject, context: host, jsEnabled: enable)
            try await context.updateTabContent(site)
            state = try state.transition(on: .startView(updatedInfo))
        case .viewing:
            break
        case .updatingJS(let settings, let subject, let urlInfo):
            context.pluginsProgram.enable(on: subject, context: urlInfo.host(), jsEnabled: settings.isJSEnabled)
            updateLoadingState(.recreateView(true))
            updateLoadingState(.reattachViewObservers)
            // Not storing DoH state in vm state, can fetch it from context
            let useIPaddress = await context.isDohEnabled()
            updateLoadingState(.load(urlInfo.urlRequest(useIPaddress)))
        }
    }
    
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func resolveDomainName(_ urlData: URLInfo) {
        // Double checking even if it was checked before
        // to not perform unnecessary network requests
        guard urlData.ipAddressString == nil else {
            let possibleState = try? state.transition(on: .createRequestAnyway(urlData.ipAddressString))
            guard let nextState = possibleState else {
                assertionFailure("Unexpected VM state when trying to `createRequestAnyway`")
                return
            }
            state = nextState
            return
        }
        
        Task {
            let apiType = await context.appAsyncApiTypeValue()
            switch apiType {
            case .reactive:
                dnsRequestSubsrciption?.dispose()
                dnsRequestSubsrciption = dnsResolver.rxResolveDomainName(urlData.platformURL)
                    .startWithResult({ [weak self] result in
                        guard let self = self else {
                            return
                        }
                        switch result {
                        case .success(let finalURL):
                            let possibleState = try? self.state.transition(on: .createRequestAnyway(finalURL.host))
                            guard let nextState = possibleState else {
                                assertionFailure("Unexpected VM state when trying to `createRequestAnyway`")
                                return
                            }
                            self.state = nextState
                        case .failure(let dnsErr):
                            print("Fail to resolve host with DNS: \(dnsErr.localizedDescription)")
                        }
                    })
            case .combine:
                dnsRequestCancellable?.cancel()
                dnsRequestCancellable = dnsResolver.cResolveDomainName(urlData.platformURL)
                    .sink(receiveCompletion: { (completion) in
                        switch completion {
                        case .failure(let dnsErr):
                            print("Fail to resolve host with DNS: \(dnsErr.localizedDescription)")
                        default:
                            break
                        }
                    }, receiveValue: { [weak self] (finalURL) in
                        guard let self = self else {
                            return
                        }
                        let possibleState = try? self.state.transition(on: .createRequestAnyway(finalURL.host))
                        guard let nextState = possibleState else {
                            assertionFailure("Unexpected VM state when trying to `createRequestAnyway`")
                            return
                        }
                        self.state = nextState
                    })
            case .asyncAwait:
                dnsRequestTaskHandler?.cancel()
                await aaResolveDomainName(urlData.platformURL)
            }
        }
    }
    
    @available(iOS 15.0, *)
    func aaResolveDomainName(_ originalURL: URL) async {
        let taskHandler = Task.detached(priority: .userInitiated) { [weak self] () -> URL in
            guard let self = self else {
                throw AppError.zombieSelf
            }
            return try await self.dnsResolver.aaResolveDomainName(originalURL)
        }
        dnsRequestTaskHandler = taskHandler
        do {
            await updateState(try await taskHandler.value)
        } catch {
            print("Fail to resolve domain name: \(error.localizedDescription)")
            await updateState(originalURL)
        }
    }
    
    func updateState(_ finalURL: URL) async {
        let possibleState = try? state.transition(on: .createRequestAnyway(finalURL.host))
        guard let nextState = possibleState else {
            assertionFailure("Unexpected VM state when trying to `createRequestAnyway`")
            return
        }
        state = nextState
    }
    
    func isNativeAppRedirectNeeded(_ url: URL) -> WKNavigationActionPolicy? {
        // Not sure why it was a check for `state.sameHost(with: url)`
        // before native app redirect, but it doesn't make sense now.
        // So, if user taps on a deep link then it doesn't matter
        // what site was open before that, we should open this url anyway.
        guard /* isSameHost && */ let newHost = url.kitHost, context.nativeApp(for: newHost) != nil else {
            return nil
        }
        let ignoreAppRawValue = WKNavigationActionPolicy.allow.rawValue + 2
        guard WKNavigationActionPolicy(rawValue: ignoreAppRawValue) != nil else {
            return nil
        }
        // swiftlint:disable:next force_unwrapping
        return WKNavigationActionPolicy(rawValue: ignoreAppRawValue)!
    }
    
    func updateLoadingState(_ state: WebPageLoadingAction) {
        Task {
            let apiType = await context.appAsyncApiTypeValue()
            switch apiType {
            case .reactive:
                rxWebPageState.value = state
            case .combine:
                combineWebPageState.value = state
            case .asyncAwait:
                webPageState = state
            }
        }
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
    
    // swiftlint:disable:next file_length
}
