//
//  WebViewModelImpl.swift
//  catowser
//
//  Created by Andrei Ermoshin on 7/26/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import WebKit
import CoreHttpKit
import CoreBrowser
import JSPlugins
import BrowserNetworking
import FeaturesFlagsKit
import ReactiveSwift
import Combine

/**
 See `decidePolicyFor` method below
 
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

final class WebViewModelImpl<Strategy>: WebViewModel where Strategy: DNSResolvingStrategy {
    /// Domain name resolver with specific strategy
    let dnsResolver: DNSResolver<Strategy>
    
    /// view model state
    private var state: WebViewModelState {
        didSet {
            do {
                try onStateChange(state)
            } catch {
                print("Wrong state: \(error.localizedDescription)")
            }
        }
    }
    
    /// reactive state property
    var rxWebPageState: MutableProperty<WebPageLoadingAction> = .init(.idle)
    /// combine state property
    var combineWebPageState: CurrentValueSubject<WebPageLoadingAction, Never> = .init(.idle)
    /// wrapped value for Published
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    @Published var webPageState: WebPageLoadingAction = .idle
    var webPageStatePublisher: Published<WebPageLoadingAction>.Publisher { $webPageState }
    
    /// Configuration should be transferred from `Site`
    var configuration: WKWebViewConfiguration {
        settings.webViewConfig
    }
    /// web view model context to access plugins and other dependencies
    let context: WebViewContext
    
    private var dnsRequestSubsrciption: Disposable?
    private lazy var dnsRequestCancellable: AnyCancellable? = nil
    @available(iOS 15.0, *)
    lazy var dnsRequestTaskHandler: Task<URL, Error>? = nil
    
    var host: Host? { state.host }
    
    var currentURL: URL? { state.url }
    
    var settings: Site.Settings { state.settings }
    
    var urlInfo: URLInfo? { state.urlInfo }
    
    var nativeAppDomainNameString: String? {
        guard let host = host, let checker = try? DomainNativeAppChecker(host: host) else {
            return nil
        }
        return checker.correspondingDomain
    }
    
    /**
     Constructs web view model
     */
    init(_ strategy: Strategy, _ site: Site, _ context: WebViewContext) {
        dnsResolver = .init(strategy)
        state = .initialized(site)
        self.context = context
    }
    
    deinit {
        dnsRequestSubsrciption?.dispose()
        dnsRequestCancellable?.cancel()
    }
    
    private func updateLoadingState(_ state: WebPageLoadingAction) {
        let apiType = FeatureManager.appAsyncApiTypeValue()
        switch apiType {
        case .reactive:
            rxWebPageState.value = state
        case .combine:
            combineWebPageState.value = state
        case .asyncAwait:
            webPageState = state
        }
    }
    
    func load() {
        do {
            state = try state.transition(on: .load)
        } catch {
            print("Wrong state on load action: " + error.localizedDescription)
        }
    }
    
    func load(url: URL) {
        do {
            state = try state.transition(on: .loadUrl(url))
        } catch {
            print("Wrong state on url load action: " + error.localizedDescription)
        }
    }
    
    func isNativeAppSchemeRedirectNeeded(_ url: URL) -> WKNavigationActionPolicy? {
        let isSameHost = state.sameHost(with: url)
        guard isSameHost && nativeAppDomainNameString != nil else {
            return nil
        }
        let ignoreAppRawValue = WKNavigationActionPolicy.allow.rawValue + 2
        guard WKNavigationActionPolicy(rawValue: ignoreAppRawValue) != nil else {
            return nil
        }
        // swiftlint:disable:next force_unwrapping
        return WKNavigationActionPolicy(rawValue: ignoreAppRawValue)!
    }
    
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func decidePolicyFor(_ navigationAction: WKNavigationAction,
                         _ decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        if let scheme = url.scheme {
            switch scheme {
            case .tel, .facetime, .facetimeAudio, .mailto:
                UIApplication.shared.open(url, options: [:])
                decisionHandler(.cancel)
                return
            default:
                break
            }
        }

        guard !url.isAppleMapsURL else {
            UIApplication.shared.open(url, options: [:])
            decisionHandler(.cancel)
            return
        }

        guard !url.isStoreURL else {
            UIApplication.shared.open(url, options: [:])
            decisionHandler(.cancel)
            return
        }
        
        if let policy = isNativeAppSchemeRedirectNeeded(url) {
            decisionHandler(policy)
            return
        } // continue execution if it is not the case
        
        guard let scheme = url.scheme else {
            decisionHandler(.allow)
            return
        }
        
        switch scheme {
        case .http, .https:
            guard  let stateHost = state.host, let nextHost = url.host else {
                decisionHandler(.allow)
                return
            }
            if stateHost.isSimilar(name: nextHost) && !url.hasIPHost {
                decisionHandler(.cancel)
                do {
                    state = try state.transition(on: .loadUrl(url))
                } catch {
                    print("Fail to load next URL due to error: \(error.localizedDescription)")
                }
            } else {
                decisionHandler(.allow)
            }
        case .about:
            decisionHandler(.allow)
        default:
            decisionHandler(.cancel)
        }
    }
    
    func finishNavigation(_ newURL: URL) {
        guard let info = state.urlInfo else {
            return
        }
        guard let updatedInfo = info.withSimilar(newURL) else {
            return
        }
        let site = Site(urlInfo: updatedInfo,
                        settings: state.settings,
                        faviconData: nil,
                        searchSuggestion: nil,
                        userSpecifiedTitle: nil)
        InMemoryDomainSearchProvider.shared.remember(host: info.host())
        
        do {
            try TabsListManager.shared.replaceSelected(tabContent: .site(site))
        } catch {
            print("\(#function) - failed to replace current tab")
        }
    }
    
    func setJavaScript(enabled: Bool) {
        guard enabled != settings.isJSEnabled else {
            return
        }
        let jsSettings = settings.withChanged(javaScriptEnabled: enabled)
        state = state.withUpdatedSettings(jsSettings)
        updateLoadingState(.recreateView(true))
        if let stateHost = state.host {
            context.jsPlugins?.inject(to: configuration.userContentController,
                                      context: stateHost,
                                      settings.canLoadPlugins)
        }
        updateLoadingState(.reattachViewObservers)
        do {
            state = try state.transition(on: .changeJavaScript(enabled))
        } catch {
            print("Wrong state on JS change action: " + error.localizedDescription)
        }
    }
    
    func finishLoading() {
        do {
            state = try state.transition(on: .finishLoading)
        } catch {
            print("Wrong state on loading finish: " + error.localizedDescription)
        }
    }
    
    func enableJSPlugins(_ subject: JavaScriptEvaluateble, _ enable: Bool) {
        context.jsPlugins?.enable(on: subject, enable: enable)
    }
}

private extension WebViewModelImpl {
    // swiftlint:disable:next cyclomatic_complexity
    func onStateChange(_ nextState: WebViewModelState) throws {
        switch nextState {
        case .initialized:
            updateLoadingState(.idle)
        case .pendingPlugins:
            let plugins: JSPlugins? = settings.canLoadPlugins ? context.pluginsBuilder?.jsPlugins : nil
            state = try state.transition(on: .injectPlugins(plugins))
        case .injectingPlugins(let plugins, let urlData, _):
            guard let host = urlData.host else {
                return
            }
            plugins.inject(to: configuration.userContentController, context: host, true)
            state = try state.transition(on: .fetchDoHStatus)
        case .pendingDoHStatus:
            let enabled = FeatureManager.boolValue(of: .dnsOverHTTPSAvailable)
            state = try state.transition(on: .resolveDomainName(enabled))
        case .checkingDNResolveSupport(let urlData, _):
            let needResolveHost = urlData.host?.isDoHSupported ?? false
            state = try state.transition(on: .checkDNResolvingSupport(needResolveHost && !urlData.hasIPHost))
        case .resolvingDN(let urlData, _):
            resolveDomainName(urlData)
        case .creatingRequest(let url, _):
            let request = URLRequest(url: url)
            state = try state.transition(on: .loadWebView(request))
        case .updatingWebView(let request, _):
            updateLoadingState(.load(request))
        case .viewing:
            break
        }
    }
    
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func resolveDomainName(_ urlData: URLData) {
        let apiType = FeatureManager.appAsyncApiTypeValue()
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
                        let possibleState = try? self.state.transition(on: .createRequestAnyway(finalURL))
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
                    let possibleState = try? self.state.transition(on: .createRequestAnyway(finalURL))
                    guard let nextState = possibleState else {
                        assertionFailure("Unexpected VM state when trying to `createRequestAnyway`")
                        return
                    }
                    self.state = nextState
                })
        case .asyncAwait:
            if #available(iOS 15.0, *) {
#if swift(>=5.5)
                dnsRequestTaskHandler?.cancel()
                Task {
                    await aaResolveDomainName(urlData.platformURL)
                }
#else
                assertionFailure("Swift version isn't 5.5")
#endif
            } else {
                assertionFailure("iOS version is not >= 15.x")
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
    
    @MainActor
    func updateState(_ finalURL: URL) async {
        let possibleState = try? state.transition(on: .createRequestAnyway(finalURL))
        guard let nextState = possibleState else {
            assertionFailure("Unexpected VM state when trying to `createRequestAnyway`")
            return
        }
        state = nextState
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
