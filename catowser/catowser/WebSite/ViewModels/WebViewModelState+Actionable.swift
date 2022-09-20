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
            return .pendingPlugins(.info(site.urlInfo), site.settings)
        case (.viewing(_, let settings), .loadNextLink(let url)):
            return .pendingPlugins(.url(url), settings)
        case (.pendingPlugins(let urlData, let settings), .injectPlugins(let pluginsProgram)):
            if let pluginsProgram = pluginsProgram {
                return .injectingPlugins(pluginsProgram, urlData, settings)
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
                return .creatingRequest(urlData.urlWithResolvedDomainName, settings)
            }
        case (.resolvingDN(_, let settings), .createRequestAnyway(let urlWithPossiblyResolvedDomainName)):
            return .creatingRequest(urlWithPossiblyResolvedDomainName, settings)
        case (.creatingRequest(_, let settings), .loadWebView(let request)):
            return .updatingWebView(request, settings)
        case (.updatingWebView(let request, let settings), .finishLoading(let finalURL, let pluginsSubject, let jsEnabled)):
            return .finishingLoading(request, settings, finalURL, pluginsSubject, jsEnabled)
        case (.finishingLoading(let request, let settings, _, _, _), .startView):
            return .viewing(request, settings)
        case (.viewing(let request, let settings), .changeJavaScript(let subject, let enabled)):
            guard settings.isJSEnabled != enabled else {
                return self
            }
            let jsSettings = settings.withChanged(javaScriptEnabled: enabled)
            return .updatingJS(request, jsSettings, subject)
        case (.updatingJS(let request, let settings, _), .finishLoading):
            return .viewing(request, settings)
        default:
            throw Error.unexpectedStateForAction
        }
    }
}
