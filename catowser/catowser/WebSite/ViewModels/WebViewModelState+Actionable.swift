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
    
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func transition(on action: Action) throws -> State {
        let nextState: State
        switch (self, action) {
        case (.initialized(let site), .loadSite):
            nextState = .pendingPlugins(.info(site.urlInfo), site.settings)
        case (.viewing(_, let settings), .loadNextLink(let url)):
            nextState = .pendingPlugins(.url(url), settings)
        case (.viewing(let request, let settings), .reload):
            nextState = .waitingForNavigation(request, settings)
        case (.viewing(let request, let settings), .goBack):
            nextState = .waitingForNavigation(request, settings)
        case (.viewing(let request, let settings), .goForward):
            nextState = .waitingForNavigation(request, settings)
        case (.pendingPlugins(let urlData, let settings), .injectPlugins(let pluginsProgram)):
            if let pluginsProgram = pluginsProgram {
                nextState = .injectingPlugins(pluginsProgram, urlData, settings)
            } else {
                nextState = .pendingDoHStatus(urlData, settings)
            }
        case (.injectingPlugins(_, let urlData, let settings), .fetchDoHStatus):
            nextState = .pendingDoHStatus(urlData, settings)
        case (.pendingPlugins(let urlData, let settings), .fetchDoHStatus):
            nextState = .pendingDoHStatus(urlData, settings)
        case (.pendingDoHStatus(let urlData, let settings), .resolveDomainName(let useDoH)):
            if useDoH {
                nextState = .checkingDNResolveSupport(urlData, settings)
            } else {
                nextState = .creatingRequest(urlData.platformURL, settings)
            }
        case (.checkingDNResolveSupport(let urlData, let settings), .checkDNResolvingSupport(let resolveNeeded)):
            if resolveNeeded {
                nextState = .resolvingDN(urlData, settings)
            } else {
                nextState = .creatingRequest(urlData.urlWithResolvedDomainName, settings)
            }
        case (.resolvingDN(_, let settings), .createRequestAnyway(let urlWithPossiblyResolvedDomainName)):
            nextState = .creatingRequest(urlWithPossiblyResolvedDomainName, settings)
        case (.creatingRequest(_, let settings), .loadWebView(let request)):
            nextState = .updatingWebView(request, settings)
        // swiftlint:disable:next line_length
        case (.updatingWebView(let request, let settings), .finishLoading(let finalURL, let pluginsSubject, let jsEnabled)):
            nextState = .finishingLoading(request, settings, finalURL, pluginsSubject, jsEnabled)
        // swiftlint:disable:next line_length
        case (.waitingForNavigation(let request, let settings), .finishLoading(let finalURL, let pluginsSubject, let jsEnabled)):
            nextState = .finishingLoading(request, settings, finalURL, pluginsSubject, jsEnabled)
        case (.finishingLoading(let request, let settings, _, _, _), .startView):
            nextState = .viewing(request, settings)
        case (.viewing(let request, let settings), .changeJavaScript(let subject, let enabled)):
            if settings.isJSEnabled == enabled {
                nextState = self
            } else {
                let jsSettings = settings.withChanged(javaScriptEnabled: enabled)
                nextState = .updatingJS(request, jsSettings, subject)
            }
        case (.updatingJS(let request, let settings, _), .finishLoading):
            nextState = .viewing(request, settings)
        default:
            print("WebViewModelState: \(self.description) -> \(action.description) -> Error")
            throw Error.unexpectedStateForAction(self, action)
        }
        
        print("WebViewModelState: \(self.description) -> \(action.description) -> \(nextState.description)")
        return nextState
    }
}
