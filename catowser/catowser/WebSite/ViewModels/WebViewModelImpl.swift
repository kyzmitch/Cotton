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

final class WebViewModelImpl<Strategy>: WebViewModel where Strategy: DNSResolvingStrategy {
    let dnsResolver: DNSResolver<Strategy>
    
    /// view model state
    private var state: WebViewState = .waitingForURL {
        didSet {
            do {
                try onStateChange(state)
            } catch {
                print("Wrong state: \(error.localizedDescription)")
            }
        }
    }
    
    var rxWebPageState: MutableProperty<WebPageLoadingState> = .init(.idle)
    var combineWebPageState: CurrentValueSubject<WebPageLoadingState, Never> = .init(.idle)
    /// wrapped value for Published
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    @Published var webPageState: WebPageLoadingState = .idle
    var webPageStatePublisher: Published<WebPageLoadingState>.Publisher { $webPageState }
    
    /// web view settings
    let settings: Site.Settings
    /// Configuration should be transferred from `Site`
    private let configuration: WKWebViewConfiguration
    /// web view model context to access plugins and other dependencies
    let context: WebViewContext
    
    /// JavaScript Plugins holder
    private(set) var jsPlugins: JSPlugins?
    
    private var dnsRequestSubsrciption: Disposable?
    private lazy var dnsRequestCancellable: AnyCancellable? = nil
    @available(iOS 15.0, *)
    lazy var dnsRequestTaskHandler: Task<URL, Error>? = nil
    
    /**
     Constructs web view model
     */
    init(_ strategy: Strategy, _ settings: Site.Settings, _ context: WebViewContext) {
        dnsResolver = .init(strategy)
        self.settings = settings
        configuration = settings.webViewConfig
        self.context = context
    }
    
    deinit {
        dnsRequestSubsrciption?.dispose()
        dnsRequestCancellable?.cancel()
    }
    
    func load(url: URL) {
        do {
            state = try state.transition(on: .loadUrl(url))
        } catch {
            print("Wrong state on load action with url: " + error.localizedDescription)
        }
    }
    
    func load(site: Site) {
        do {
            state = try state.transition(on: .loadSite(site))
        } catch {
            print("Wrong state on load action with site: " + error.localizedDescription)
        }
    }
    
    private func onStateChange(_ nextState: WebViewState) throws {
        switch nextState {
        case .waitingForURL:
            // Notify view layer - clear view
            break
        case .pendingPlugins:
            let plugins: [JavaScriptPlugin]? = settings.canLoadPlugins ? context.pluginsBuilder?.plugins : nil
            state = try state.transition(on: .injectPlugins(plugins))
        case .injectingPlugins(let plugins, let urlData):
            jsPlugins = JSPlugins(plugins)
            guard let host = urlData.host else {
                return
            }
            jsPlugins?.inject(to: configuration.userContentController, context: host, true)
            state = try state.transition(on: .fetchDoHStatus)
        case .pendingDoHStatus:
            let enabled = FeatureManager.boolValue(of: .dnsOverHTTPSAvailable)
            state = try state.transition(on: .resolveDomainName(enabled))
        case .checkingDNResolveSupport(let urlData):
            let needResolveHost = urlData.host?.isDoHSupported ?? false
            state = try state.transition(on: .checkDNResolvingSupport(needResolveHost && !urlData.hasIPHost))
        case .resolvingDN(let urlData):
            resolveDomainName(urlData)
        case .creatingRequest(let url):
            let request = URLRequest(url: url)
            state = try state.transition(on: .loadWebView(request))
        case .updatingWebView(let request):
            let apiType = FeatureManager.appAsyncApiTypeValue()
            switch apiType {
            case .reactive:
                rxWebPageState.value = .load(request)
            case .combine:
                combineWebPageState.value = .load(request)
            case .asyncAwait:
                webPageState = .load(request)
            }
        }
    }
    
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func resolveDomainName(_ urlData: URLData) {
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
    private func aaResolveDomainName(_ originalURL: URL) async {
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
    private func updateState(_ finalURL: URL) async {
        let possibleState = try? state.transition(on: .createRequestAnyway(finalURL))
        guard let nextState = possibleState else {
            assertionFailure("Unexpected VM state when trying to `createRequestAnyway`")
            return
        }
        state = nextState
    }
}
