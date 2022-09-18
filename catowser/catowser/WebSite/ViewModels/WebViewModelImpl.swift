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
    lazy var dnsRequestTaskHandler: Task<URL, Error>? = nil
    
    var host: Host { state.host }
    
    var currentURL: URL? { state.url }
    
    var settings: Site.Settings { state.settings }
    
    var urlInfo: URLInfo? { state.urlInfo }
    
    var nativeAppDomainNameString: String? {
        guard let checker = try? DomainNativeAppChecker(host: host) else {
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
            state = try state.transition(on: .loadSite)
        } catch {
            print("Wrong state on load action: " + error.localizedDescription)
        }
    }
    
    func finishLoading(_ newURL: URL, _ subject: JavaScriptEvaluateble) {
        /**
         you must inject/re-enable plugins even if web view loaded page from same Host
         and even if ip address is used instead of domain name
         */
        let jsEnabled = FeatureManager.boolValue(of: .javaScriptEnabled)
        do {
            state = try state.transition(on: .finishLoading(newURL, subject, jsEnabled))
        } catch {
            print("\(#function) - failed to replace current tab: " + error.localizedDescription)
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
            guard state.url != url else {
                decisionHandler(.allow)
                return
            }
            guard let nextHost = url.host else {
                decisionHandler(.allow)
                return
            }
            if state.host.isSimilar(name: nextHost) && !url.hasIPHost {
                decisionHandler(.cancel)
                do {
                    state = try state.transition(on: .loadNextLink(url))
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
    
    func setJavaScript(_ subject: JavaScriptEvaluateble, _ enabled: Bool) {
        do {
            state = try state.transition(on: .changeJavaScript(subject, enabled))
        } catch {
            print("Wrong state on JS change action: " + error.localizedDescription)
        }
    }
}

private extension WebViewModelImpl {
    func onStateChange(_ nextState: WebViewModelState) throws {
        switch nextState {
        case .initialized:
            updateLoadingState(.idle)
        case .pendingPlugins:
            let pluginsProgram: JSPluginsProgram? = settings.canLoadPlugins ? context.pluginsProgram : nil
            state = try state.transition(on: .injectPlugins(pluginsProgram))
        case .injectingPlugins(let pluginsProgram, let urlData, _):
            pluginsProgram.inject(to: configuration.userContentController, context: urlData.host, true)
            state = try state.transition(on: .fetchDoHStatus)
        case .pendingDoHStatus:
            let enabled = FeatureManager.boolValue(of: .dnsOverHTTPSAvailable)
            state = try state.transition(on: .resolveDomainName(enabled))
        case .checkingDNResolveSupport(let urlData, _):
            let dohWillWork = urlData.host.isDoHSupported
            // somehow url from site already or from next page request
            // contained ip address
            let domainNameAlreadyResolved = urlData.hasIPHost
            state = try state.transition(on: .checkDNResolvingSupport(dohWillWork && !domainNameAlreadyResolved))
        case .resolvingDN(let urlData, _):
            resolveDomainName(urlData)
        case .creatingRequest(let url, _):
            let request = URLRequest(url: url)
            state = try state.transition(on: .loadWebView(request))
        case .updatingWebView(let request, _):
            updateLoadingState(.load(request))
        case .finishingLoading(let request, let settings, let newURL, let subject, let enable):
            // swiftlint:disable:next force_unwrapping
            let url = request.url!
            // swiftlint:disable:next force_unwrapping
            let info = URLInfo(url)!
            // swiftlint:disable:next force_unwrapping
            let updatedInfo = info.withSimilar(newURL)!
            let site = Site.create(urlInfo: updatedInfo, settings: settings)
            InMemoryDomainSearchProvider.shared.remember(host: updatedInfo.host())
            context.pluginsProgram.enable(on: subject, enable: enable)
            try TabsListManager.shared.replaceSelected(tabContent: .site(site))
            state = try state.transition(on: .startView)
        case .viewing:
            break
        case .updatingJS(let request, let settings, let subject):
            context.pluginsProgram.enable(on: subject, enable: settings.isJSEnabled)
            updateLoadingState(.recreateView(true))
            updateLoadingState(.reattachViewObservers)
            updateLoadingState(.load(request))
        }
    }
    
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func resolveDomainName(_ urlData: URLData) {
        // Double checking even if it was checked before
        // to not perform unnecessary network requests
        guard !urlData.hasIPHost else {
            let possibleState = try? state.transition(on: .createRequestAnyway(urlData.urlWithResolvedDomainName))
            guard let nextState = possibleState else {
                assertionFailure("Unexpected VM state when trying to `createRequestAnyway`")
                return
            }
            state = nextState
            return
        }
        
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
