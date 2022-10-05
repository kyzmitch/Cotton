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
    case injectingPlugins(JSPluginsProgram, URLData, Site.Settings)
    case pendingDoHStatus(URLData, Site.Settings)
    case checkingDNResolveSupport(URLData, Site.Settings)
    case resolvingDN(URLData, Site.Settings)
    case creatingRequest(URL, Site.Settings)
    case updatingWebView(URLRequest, Site.Settings)
    case waitingForNavigation(URLRequest, Site.Settings)
    case finishingLoading(URLRequest, Site.Settings, URL, JavaScriptEvaluateble, _ jsEnabled: Bool)
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
        case .creatingRequest(let uRL, _):
            // swiftlint:disable:next force_unwrapping
            return uRL.kitHost!
        case .updatingWebView(let uRLRequest, _):
            // swiftlint:disable:next force_unwrapping
            let url = uRLRequest.url!
            // swiftlint:disable:next force_unwrapping
            return url.kitHost!
        case .waitingForNavigation(let uRLRequest, _):
            // swiftlint:disable:next force_unwrapping
            let url = uRLRequest.url!
            // swiftlint:disable:next force_unwrapping
            return url.kitHost!
        case .finishingLoading(let request, _, _, _, _):
            // swiftlint:disable:next force_unwrapping
            return request.url!.kitHost!
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
        case .creatingRequest(let uRL, _):
            return uRL
        case .updatingWebView(let uRLRequest, _):
            // swiftlint:disable:next force_unwrapping
            return uRLRequest.url!
        case .waitingForNavigation(let uRLRequest, _):
            // swiftlint:disable:next force_unwrapping
            return uRLRequest.url!
        case .finishingLoading(let request, _, _, _, _):
            // swiftlint:disable:next force_unwrapping
            return request.url!
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
        case .updatingWebView(_, let settings):
            return settings
        case .waitingForNavigation(_, let settings):
            return settings
        case .finishingLoading(_, let settings, _, _, _):
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
        case .creatingRequest(let uRL, _):
            return uRL.host == url.host
        case .updatingWebView(let uRLRequest, _):
            return uRLRequest.url?.host == url.host
        case .waitingForNavigation(let uRLRequest, _):
            return uRLRequest.url?.host == url.host
        case .finishingLoading(let request, _, _, _, _):
            return request.url?.host == url.host
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
        case .creatingRequest(let uRL, _):
            return .url(uRL)
        case .updatingWebView(let uRLRequest, _):
            // swiftlint:disable:next force_unwrapping
            let uRL = uRLRequest.url!
            return .url(uRL)
        case .waitingForNavigation(let uRLRequest, _):
            // swiftlint:disable:next force_unwrapping
            let uRL = uRLRequest.url!
            return .url(uRL)
        case .finishingLoading(let uRLRequest, _, _, _, _):
            // swiftlint:disable:next force_unwrapping
            let uRL = uRLRequest.url!
            return .url(uRL)
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
        case .initialized(_):
            return "initialized"
        case .pendingPlugins(_, _):
            return "pendingPlugins"
        case .injectingPlugins(_, _, _):
            return "injectingPlugins"
        case .pendingDoHStatus(_, _):
            return "pendingDoHStatus"
        case .checkingDNResolveSupport(_, _):
            return "checkingDNResolveSupport"
        case .resolvingDN(_, _):
            return "resolvingDN"
        case .creatingRequest(_, _):
            return "creatingRequest"
        case .updatingWebView(_, _):
            return "updatingWebView"
        case .waitingForNavigation(_, _):
            return "waitingForNavigation"
        case .finishingLoading(_, _, _, _, _):
            return "finishingLoading"
        case .viewing(_, _):
            return "viewing"
        case .updatingJS(_, _, _):
            return "updatingJS"
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
            return lProgram == rProgram && lData == rData && lSettings == rSettings
        case (.updatingWebView(let lRequest, let lSettings), .updatingWebView(let rRequest, let rSettings)):
            return lRequest == rRequest && lSettings == rSettings
        case (.viewing(let lRequest, let lSettings), .viewing(let rRequest, let rSettings)):
            return lRequest == rRequest && lSettings == rSettings
        default:
            return false
        }
    }
}
