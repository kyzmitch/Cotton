//
//  WebViewModelState.swift
//  catowser
//
//  Created by Andrei Ermoshin on 8/27/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import CoreHttpKit
import JSPlugins
import CoreBrowser

enum WebViewModelState {
    case initialized(Site)
    case pendingPlugins(URLData, Site.Settings)
    case injectingPlugins(any JSPluginsProgram, URLData, Site.Settings)
    case pendingDoHStatus(URLData, Site.Settings)
    case checkingDNResolveSupport(URLData, Site.Settings)
    case resolvingDN(URLData, Site.Settings)
    case creatingRequest(URLData, Site.Settings)
    /// `URLRequest` could have ip address in URL host, so, keeping URLData as well, to not forget original host
    case updatingWebView(URLRequest, Site.Settings, URLData)
    case waitingForNavigation(URLRequest, Site.Settings)
    case finishingLoading(URLRequest, Site.Settings, URL, JavaScriptEvaluateble, _ jsEnabled: Bool, URLData)
    case viewing(URLRequest, Site.Settings)
    
    case updatingJS(URLRequest, Site.Settings, JavaScriptEvaluateble)
    
    enum Error: LocalizedError {
        case unexpectedStateForAction(WebViewModelState, WebViewAction)
        case notImplemented
        
        public var localizedDescription: String {
            switch self {
            case .unexpectedStateForAction(let state, let action):
                return "Unexpected state \(state.description) for action \(action.description)"
            case .notImplemented:
                return "Not implemented"
            }
        }
    }
    
    /// Returns host with domain name (ignore ip address as a host even if it is present)
    var host: Host {
        switch self {
        case .initialized(let site):
            return site.host
        case .pendingPlugins(let uRLData, _):
            return uRLData.host
        case .injectingPlugins(_, let uRLData, _):
            return uRLData.host
        case .pendingDoHStatus(let uRLData, _):
            return uRLData.host
        case .checkingDNResolveSupport(let uRLData, _):
            return uRLData.host
        case .resolvingDN(let uRLData, _):
            return uRLData.host
        case .creatingRequest(let uRLData, _):
            return uRLData.host
        case .updatingWebView(_, _, let urlData):
            // Returns host with domain name, but it is possible to return host with ip address as well
            return urlData.host
        case .waitingForNavigation(let uRLRequest, _):
            // swiftlint:disable:next force_unwrapping
            let url = uRLRequest.url!
            // swiftlint:disable:next force_unwrapping
            return url.kitHost!
        case .finishingLoading(_, _, _, _, _, let urlData):
            return urlData.host
        case .viewing(let uRLRequest, _):
            // swiftlint:disable:next force_unwrapping
            let url = uRLRequest.url!
            // swiftlint:disable:next force_unwrapping
            return url.kitHost!
        case .updatingJS(let uRLRequest, _, _):
            // swiftlint:disable:next force_unwrapping
            let url = uRLRequest.url!
            // swiftlint:disable:next force_unwrapping
            return url.kitHost!
        }
    }
    
    /// Return URL with domain name, not with ip address as a host
    var url: URL {
        switch self {
        case .initialized(let site):
            return site.urlInfo.platformURL
        case .pendingPlugins(let uRLData, _):
            return uRLData.platformURL
        case .injectingPlugins(_, let uRLData, _):
            return uRLData.platformURL
        case .pendingDoHStatus(let uRLData, _):
            return uRLData.platformURL
        case .checkingDNResolveSupport(let uRLData, _):
            return uRLData.platformURL
        case .resolvingDN(let uRLData, _):
            return uRLData.platformURL
        case .creatingRequest(let uRLData, _):
            return uRLData.platformURL
        case .updatingWebView(_, _, let uRLData):
            return uRLData.platformURL
        case .waitingForNavigation(let uRLRequest, _):
            // swiftlint:disable:next force_unwrapping
            return uRLRequest.url!
        case .finishingLoading(_, _, _, _, _, let uRLData):
            return uRLData.platformURL
        case .viewing(let request, _):
            // swiftlint:disable:next force_unwrapping
            return request.url!
        case .updatingJS(let request, _, _):
            // swiftlint:disable:next force_unwrapping
            return request.url!
        }
    }
    
    var settings: Site.Settings {
        switch self {
        case .initialized(let site):
            return site.settings
        case .pendingPlugins(_, let settings):
            return settings
        case .injectingPlugins(_, _, let settings):
            return settings
        case .pendingDoHStatus(_, let settings):
            return settings
        case .checkingDNResolveSupport(_, let settings):
            return settings
        case .resolvingDN(_, let settings):
            return settings
        case .creatingRequest(_, let settings):
            return settings
        case .updatingWebView(_, let settings, _):
            return settings
        case .waitingForNavigation(_, let settings):
            return settings
        case .finishingLoading(_, let settings, _, _, _, _):
            return settings
        case .viewing(_, let settings):
            return settings
        case .updatingJS(_, let settings, _):
            return settings
        }
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    func sameHost(with url: URL) -> Bool {
        switch self {
        case .initialized(let site):
            return site.host.isSimilar(with: url)
        case .pendingPlugins(let uRLData, _):
            return uRLData.sameHost(with: url)
        case .injectingPlugins(_, let uRLData, _):
            return uRLData.sameHost(with: url)
        case .pendingDoHStatus(let uRLData, _):
            return uRLData.sameHost(with: url)
        case .checkingDNResolveSupport(let uRLData, _):
            return uRLData.sameHost(with: url)
        case .resolvingDN(let uRLData, _):
            return uRLData.sameHost(with: url)
        case .creatingRequest(let uRLData, _):
            return uRLData.sameHost(with: url)
        case .updatingWebView(_, _, let urlData):
            return urlData.host.rawString == url.host || urlData.ipAddress == url.host
        case .waitingForNavigation(let uRLRequest, _):
            return uRLRequest.url?.host == url.host
        case .finishingLoading(_, _, _, _, _, let urlData):
            return urlData.host.rawString == url.host || urlData.ipAddress == url.host
        case .viewing(let request, _):
            return request.url?.host == url.host
        case .updatingJS(let request, _, _):
            return request.url?.host == url.host
        }
    }
    
    var urlData: URLData {
        switch self {
        case .initialized(let site):
            return .info(site.urlInfo)
        case .pendingPlugins(let uRLData, _):
            return uRLData
        case .injectingPlugins(_, let uRLData, _):
            return uRLData
        case .pendingDoHStatus(let uRLData, _):
            return uRLData
        case .checkingDNResolveSupport(let uRLData, _):
            return uRLData
        case .resolvingDN(let uRLData, _):
            return uRLData
        case .creatingRequest(let uRLData, _):
            return uRLData
        case .updatingWebView(_, _, let urlData):
            return urlData
        case .waitingForNavigation(let uRLRequest, _):
            // swiftlint:disable:next force_unwrapping
            let uRL = uRLRequest.url!
            return .url(uRL)
        case .finishingLoading(_, _, _, _, _, let urlData):
            return urlData
        case .viewing(let uRLRequest, _):
            // swiftlint:disable:next force_unwrapping
            let uRL = uRLRequest.url!
            return .url(uRL)
        case .updatingJS(let uRLRequest, _, _):
            // swiftlint:disable:next force_unwrapping
            let uRL = uRLRequest.url!
            return .url(uRL)
        }
    }
    
    var urlInfo: URLInfo? {
        switch urlData {
        case .url(let uRL):
            return URLInfo(uRL)
        case .info(let uRLInfo):
            return uRLInfo
        }
    }
}

extension WebViewModelState: CustomStringConvertible {
    var description: String {
        switch self {
        case .initialized(let site):
#if DEBUG
            return "initialized (\(site.urlInfo.url))"
#else
            return "initialized"
#endif
        case .pendingPlugins(_, _):
            return "pendingPlugins"
        case .injectingPlugins(_, _, _):
            return "injectingPlugins"
        case .pendingDoHStatus(_, _):
            return "pendingDoHStatus"
        case .checkingDNResolveSupport(_, _):
            return "checkingDNResolveSupport"
        case .resolvingDN(let urlData, let settings):
#if DEBUG
            return "resolvingDN (\(urlData.description), \(settings.description))"
#else
            return "resolvingDN"
#endif
        case .creatingRequest(_, _):
            return "creatingRequest"
        case .updatingWebView(let request, _, let urlData):
#if DEBUG
            // swiftlint:disable:next force_unwrapping
            return "updatingWebView (\(request.url!.absoluteString) --> \(urlData.description))"
#else
            return "updatingWebView"
#endif
        case .waitingForNavigation(_, _):
            return "waitingForNavigation"
        case .finishingLoading(let request, _, _, _, _, let urlData):
#if DEBUG
            // swiftlint:disable:next force_unwrapping
            return "finishingLoading (\(request.url!.absoluteString) -->> ip address \(urlData.ipAddress ?? "none"))"
#else
            return "finishingLoading"
#endif
        case .viewing(_, _):
            return "viewing"
        case .updatingJS(let request, let settings, let jsSubject):
#if DEBUG
            // swiftlint:disable:next force_unwrapping
            return "updatingJS (\(request.url!.absoluteString), \(settings.description))"
#else
            return "updatingJS"
#endif
        }
    }
}

extension WebViewModelState: Equatable {
    static func == (lhs: WebViewModelState, rhs: WebViewModelState) -> Bool {
        switch (lhs, rhs) {
        case (.initialized(let lSite), .initialized(let rSite)):
            return lSite == rSite
        case (.pendingPlugins(let lData, let lSettings), .pendingPlugins(let rData, let rSettings)):
            return lData == rData && lSettings == rSettings
        case (.injectingPlugins(let lProgram, let lData, let lSettings),
              .injectingPlugins(let rProgram, let rData, let rSettings)):
            if let lp = lProgram as? JSPluginsProgramImpl, let rp = rProgram as? JSPluginsProgramImpl, lp != rp {
                return false
            }
            return lData == rData && lSettings == rSettings
        case (.updatingWebView(let lRequest, let lSettings, let lData),
              .updatingWebView(let rRequest, let rSettings, let rData)):
            return lRequest == rRequest && lSettings == rSettings && lData == rData
        case (.viewing(let lRequest, let lSettings), .viewing(let rRequest, let rSettings)):
            return lRequest == rRequest && lSettings == rSettings
        case (.waitingForNavigation(let lRequest, let lSettings), .waitingForNavigation(let rRequest, let rSettings)):
            return lRequest == rRequest && lSettings == rSettings
        case (.resolvingDN(let lData, let lSettings),
              .resolvingDN(let rData, let rSettings)):
            return lData == rData && lSettings == rSettings
        case (.updatingJS(let lRequest, let lSettings, let lSubject),
              .updatingJS(let rRequest, let rSettings, let rSubject)):
            return lRequest == rRequest && lSettings == rSettings /* && lSubject === rSubject */
        default:
            return false
        }
    }
}
