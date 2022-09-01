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

enum WebViewModelState {
    case initialized(Site)
    case pendingPlugins(URLData, Site.Settings)
    case injectingPlugins(JSPluginsProgram, URLData, Site.Settings)
    case pendingDoHStatus(URLData, Site.Settings)
    case checkingDNResolveSupport(URLData, Site.Settings)
    case resolvingDN(URLData, Site.Settings)
    case creatingRequest(URL, Site.Settings)
    case updatingWebView(URLRequest, Site.Settings)
    case viewing(URLRequest, Site.Settings)
    
    enum Error: LocalizedError {
        case unexpectedStateForAction
        case notImplemented
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
        case .viewing(let uRLRequest, _):
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
        case .viewing(let request, _):
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
        case .viewing(_, let settings):
            return settings
        }
    }
    
    func withUpdatedSettings(_ newSettings: Site.Settings) -> WebViewModelState {
        switch self {
        case .initialized(let site):
            return .initialized(site.withUpdated(newSettings))
        case .pendingPlugins(let uRLData, _):
            return .pendingPlugins(uRLData, newSettings)
        case .injectingPlugins(let array, let uRLData, _):
            return .injectingPlugins(array, uRLData, newSettings)
        case .pendingDoHStatus(let uRLData, _):
            return .pendingDoHStatus(uRLData, newSettings)
        case .checkingDNResolveSupport(let uRLData, _):
            return .checkingDNResolveSupport(uRLData, newSettings)
        case .resolvingDN(let uRLData, _):
            return .resolvingDN(uRLData, newSettings)
        case .creatingRequest(let uRL, _):
            return .creatingRequest(uRL, newSettings)
        case .updatingWebView(let uRLRequest, _):
            return .updatingWebView(uRLRequest, newSettings)
        case .viewing(let request, _):
            return .viewing(request, newSettings)
        }
    }
    
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
        case .viewing(let request, _):
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
        case .viewing(let uRLRequest, _):
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
