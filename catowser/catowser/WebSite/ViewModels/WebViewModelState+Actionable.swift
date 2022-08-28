//
//  WebViewModelState+Actionable.swift
//  catowser
//
//  Created by Andrei Ermoshin on 8/27/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import CoreHttpKit
import JSPlugins

extension WebViewModelState: Actionable {
    typealias Action = WebViewAction
    typealias State = Self
    
    // swiftlint:disable:next cyclomatic_complexity
    func transition(on action: Action) throws -> State {
        switch (self, action) {
        case (.initialized(let site), .loadSite):
            return .pendingPlugins(.url(site.urlInfo.platformURL), site.settings)
        case (.viewing(_, let settings), .loadNextLink(let url)):
            return .pendingPlugins(.url(url), settings)
        case (.pendingPlugins(let urlData, let settings), .injectPlugins(let plugins)):
            if let plugins = plugins {
                return .injectingPlugins(plugins, urlData, settings)
            } else {
                return .pendingDoHStatus(urlData, settings)
            }
        case (.injectingPlugins(_, let urlData, let settings), .fetchDoHStatus):
            return .pendingDoHStatus(urlData, settings)
        case (.pendingPlugins(let urlData, let settings), .fetchDoHStatus):
            return .pendingDoHStatus(urlData, settings)
        case (.pendingDoHStatus(let urlData, let settings), .resolveDomainName(let useDoH)):
            if useDoH {
                return .checkingDNResolveSupport(urlData, settings)
            } else {
                return .creatingRequest(urlData.platformURL, settings)
            }
        case (.checkingDNResolveSupport(let urlData, let settings), .checkDNResolvingSupport(let resolveNeeded)):
            if resolveNeeded {
                return .resolvingDN(urlData, settings)
            } else {
                return .creatingRequest(urlData.platformURL, settings)
            }
        case (.resolvingDN(_, let settings), .createRequestAnyway(let url)):
            return .creatingRequest(url, settings)
        case (.creatingRequest(_, let settings), .loadWebView(let request)):
            return .updatingWebView(request, settings)
        case (.updatingWebView(let request, let settings), .finishLoading):
            return .viewing(request, settings) // to still be able to read URL after loading
        case (.viewing, .changeJavaScript):
            throw Error.notImplemented
        default:
            throw Error.unexpectedStateForAction
        }
    }
}
