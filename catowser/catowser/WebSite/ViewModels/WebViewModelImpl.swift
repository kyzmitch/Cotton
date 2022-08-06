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

final class WebViewModelImpl<Strategy>: WebViewModel where Strategy: DNSResolvingStrategy {
    let dnsResolver: DNSResolver<Strategy>
    
    /// view model state
    private var state: WebViewState = .waitingForURL {
        didSet {
            onStateChange(state)
        }
    }
    
    /// web view settings
    let settings: Site.Settings
    /// Configuration should be transferred from `Site`
    private let configuration: WKWebViewConfiguration
    /// web view model context to access plugins and other dependencies
    let context: WebViewContext
    
    /// JavaScript Plugins holder
    private(set) var jsPlugins: JSPlugins?
    
    /**
     Constructs web view model
     */
    init(_ strategy: Strategy, _ settings: Site.Settings, _ context: WebViewContext) {
        dnsResolver = .init(strategy)
        self.settings = settings
        configuration = settings.webViewConfig
        self.context = context
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
    
    private func onStateChange(_ nextState: WebViewState) {
        do {
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
            case .updatingWebView:
                // Notify View layer - load content
                break
            default:
                break
            }
        } catch {
            print("Wrong state: \(error.localizedDescription)")
        }
    }
    
    private func resolveDomainName(_ urlData: URLData) {
        
        
        /**
         let ipAddress: IPAddress? = nil
         state = try state.transition(on: .hideDomainName(ipAddress))
         break
         */
    }
}
