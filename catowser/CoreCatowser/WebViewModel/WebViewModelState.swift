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
    case pendingPlugins(URLInfo, Site.Settings)
    case injectingPlugins(any JSPluginsProgram, URLInfo, Site.Settings)
    case pendingDoHStatus(URLInfo, Site.Settings)
    case checkingDNResolveSupport(URLInfo, Site.Settings)
    case resolvingDN(URLInfo, Site.Settings)
    case creatingRequest(URLInfo, Site.Settings)
    /// `URLRequest` could have ip address in URL host, so, keeping URLInfo as well, to not forget original host
    case updatingWebView(URLRequest, Site.Settings, URLInfo)
    case waitingForNavigation(URLRequest, Site.Settings, URLInfo)
    case finishingLoading(URLRequest, Site.Settings, URL, JavaScriptEvaluateble, _ jsEnabled: Bool, URLInfo)
    case viewing(URLRequest, Site.Settings, URLInfo)
    
    case updatingJS(URLRequest, Site.Settings, JavaScriptEvaluateble, URLInfo)
    
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
            return uRLData.host()
        case .injectingPlugins(_, let uRLData, _):
            return uRLData.host()
        case .pendingDoHStatus(let uRLData, _):
            return uRLData.host()
        case .checkingDNResolveSupport(let uRLData, _):
            return uRLData.host()
        case .resolvingDN(let uRLData, _):
            return uRLData.host()
        case .creatingRequest(let uRLData, _):
            return uRLData.host()
        case .updatingWebView(_, _, let urlData):
            // Returns host with domain name, but it is possible to return host with ip address as well
            // host from request argument can't be used, because it could contain an ip address
            return urlData.host()
        case .waitingForNavigation(_, _, let urlInfo):
            return urlInfo.host()
        case .finishingLoading(_, _, _, _, _, let urlData):
            return urlData.host()
        case .viewing(_, _, let uRLInfo):
            return uRLInfo.host()
        case .updatingJS(_, _, _, let uRLInfo):
            return uRLInfo.host()
        }
    }
    
    /// Returns URL with domain name, not with ip address as a host
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
        case .waitingForNavigation(_, _, let uRLData):
            return uRLData.platformURL
        case .finishingLoading(_, _, _, _, _, let uRLData):
            return uRLData.platformURL
        case .viewing(_, _, let uRLInfo):
            return uRLInfo.platformURL
        case .updatingJS(_, _, _, let uRLData):
            return uRLData.platformURL
        }
    }
    
    /// Returns settings which are always present in any VM state
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
        case .waitingForNavigation(_, let settings, _):
            return settings
        case .finishingLoading(_, let settings, _, _, _, _):
            return settings
        case .viewing(_, let settings, _):
            return settings
        case .updatingJS(_, let settings, _, _):
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
            return urlData.host().rawString == url.host || urlData.ipAddressString == url.host
        case .waitingForNavigation(_, _, let urlData):
            return urlData.host().rawString == url.host || urlData.ipAddressString == url.host
        case .finishingLoading(_, _, _, _, _, let urlData):
            return urlData.host().rawString == url.host || urlData.ipAddressString == url.host
        case .viewing(_, _, let uRLInfo):
            return uRLInfo.host().rawString == url.host || uRLInfo.ipAddressString == url.host
        case .updatingJS(_, _, _, let uRLInfo):
            return uRLInfo.host().rawString == url.host || uRLInfo.ipAddressString == url.host
        }
    }
    
    var urlInfo: URLInfo {
        switch self {
        case .initialized(let site):
            return site.urlInfo
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
        case .updatingWebView(_, _, let uRLData):
            return uRLData
        case .waitingForNavigation(_, _, let urlInfo):
            return urlInfo
        case .finishingLoading(_, _, _, _, _, let urlData):
            return urlData
        case .viewing(_, _, let uRLInfo):
            return uRLInfo
        case .updatingJS(_, _, _, let uRLInfo):
            return uRLInfo
        }
    }

}

extension WebViewModelState: CustomStringConvertible {
    var description: String {
        switch self {
        case .initialized(let site):
#if DEBUG
            return "initialized (\(site.urlInfo.debugDescription))"
#else
            return "initialized"
#endif
        case .pendingPlugins:
            return "pendingPlugins"
        case .injectingPlugins:
            return "injectingPlugins"
        case .pendingDoHStatus:
            return "pendingDoHStatus"
        case .checkingDNResolveSupport:
            return "checkingDNResolveSupport"
        case .resolvingDN(let urlData, let settings):
#if DEBUG
            return "resolvingDN (\(urlData.debugDescription), \(settings.description))"
#else
            return "resolvingDN"
#endif
        case .creatingRequest:
            return "creatingRequest"
        case .updatingWebView(let request, _, let urlData):
#if DEBUG
            return "updatingWebView (request[\(request.url?.absoluteString ?? "none")], [\(urlData.debugDescription)])"
#else
            return "updatingWebView"
#endif
        case .waitingForNavigation(let request, _, let urlInfo):
#if DEBUG
            return "waitingForNavigation (request[\(request.url?.absoluteString ?? "none")], [\(urlInfo.debugDescription)])"
#else
            return "waitingForNavigation"
#endif
        case .finishingLoading(let request, _, _, _, _, let urlInfo):
#if DEBUG
            return "finishingLoading (request[\(request.url?.absoluteString ?? "none")], [\(urlInfo.debugDescription)])"
#else
            return "finishingLoading"
#endif
        case .viewing:
            return "viewing"
        case .updatingJS(let request, let settings, _, let urlData):
#if DEBUG
            return "updatingJS (request[\(request.url?.absoluteString ?? "none")], settings[\(settings.description)], [\(urlData.debugDescription)]"
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
        case (.viewing(let lRequest, let lSettings, let lInfo),
              .viewing(let rRequest, let rSettings, let rInfo)):
            return lRequest == rRequest && lSettings == rSettings && lInfo == rInfo
        case (.waitingForNavigation(let lRequest, let lSettings, let lInfo),
              .waitingForNavigation(let rRequest, let rSettings, let rInfo)):
            return lRequest == rRequest && lSettings == rSettings && lInfo == rInfo
        case (.resolvingDN(let lData, let lSettings),
              .resolvingDN(let rData, let rSettings)):
            return lData == rData && lSettings == rSettings
        case (.updatingJS(let lRequest, let lSettings, let lSubject, let lInfo),
              .updatingJS(let rRequest, let rSettings, let rSubject, let rInfo)):
            return lRequest == rRequest && lSettings == rSettings && lInfo == rInfo && lSubject === rSubject
        default:
            return false
        }
    }
}
