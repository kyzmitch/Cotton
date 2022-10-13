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
        case (.initialized(let site),
              .loadSite):
            nextState = .pendingPlugins(site.urlInfo, site.settings)
        case (.viewing(let settings, _),
              .loadNextLink(let url)):
            // DoH can be optimized here, if previous URLInfo had same host and resolved ip address
            // swiftlint:disable:next force_unwrapping
            let urlInfo: URLInfo = .init(url)!
            nextState = .pendingPlugins(urlInfo, settings)
        case (.viewing(let settings, let uRLInfo),
              .reload):
            nextState = .waitingForNavigation(settings, uRLInfo)
        case (.viewing(let settings, let uRLInfo),
              .goBack):
            nextState = .waitingForNavigation(settings, uRLInfo)
        case (.viewing(let settings, let uRLInfo),
              .goForward):
            nextState = .waitingForNavigation(settings, uRLInfo)
        case (.pendingPlugins(let urlInfo, let settings),
              .injectPlugins(let pluginsProgram)):
            if let pluginsProgram = pluginsProgram {
                nextState = .injectingPlugins(pluginsProgram, urlInfo, settings)
            } else {
                nextState = .pendingDoHStatus(urlInfo, settings)
            }
        case (.injectingPlugins(_, let urlData, let settings),
              .fetchDoHStatus):
            nextState = .pendingDoHStatus(urlData, settings)
        case (.pendingPlugins(let urlData, let settings),
              .fetchDoHStatus):
            nextState = .pendingDoHStatus(urlData, settings)
        case (.pendingDoHStatus(let urlData, let settings),
              .resolveDomainName(let useDoH)):
            if useDoH {
                nextState = .checkingDNResolveSupport(urlData, settings)
            } else {
                nextState = .creatingRequest(urlData, settings)
            }
        case (.checkingDNResolveSupport(let urlData, let settings),
              .checkDNResolvingSupport(let resolveNeeded)):
            if resolveNeeded {
                nextState = .resolvingDN(urlData, settings)
            } else {
                nextState = .creatingRequest(urlData, settings)
            }
        case (.resolvingDN(let urlData, let settings),
              .createRequestAnyway(let ipAddress)):
            let updatedUrlData: URLInfo
            if let address = ipAddress {
                updatedUrlData = urlData.withIPAddress(ipAddress: address)
            } else {
                updatedUrlData = urlData
            }
            nextState = .creatingRequest(updatedUrlData, settings)
        case (.creatingRequest(let urlData, let settings),
              .loadWebView):
            nextState = .updatingWebView(settings, urlData)
        case (.updatingWebView(let settings, let urlData),
              .finishLoading(let finalURL, let pluginsSubject, let jsEnabled)):
            nextState = .finishingLoading(settings, finalURL, pluginsSubject, jsEnabled, urlData)
        case (.waitingForNavigation(let settings, let uRLData),
              .finishLoading(let finalURL, let pluginsSubject, let jsEnabled)):
            nextState = .finishingLoading(settings, finalURL, pluginsSubject, jsEnabled, uRLData)
        case (.finishingLoading(let settings, _, _, _, let urlData),
              .startView):
            nextState = .viewing(settings, urlData)
        case (.viewing(let settings, let urlInfo),
              .changeJavaScript(let subject, let enabled)):
            if settings.isJSEnabled == enabled {
                nextState = self
            } else {
                let jsSettings = settings.withChanged(javaScriptEnabled: enabled)
                nextState = .updatingJS(jsSettings, subject, urlInfo)
            }
        case (.updatingJS(let settings, _, let urlInfo),
              .finishLoading):
            // No need to use middle `finishingLoading` state because
            // we can be sure that finalURL during JS update web view reload
            // stays the same, because `.changeJavaScript` action is very similar to `.reload`.
            // Also, we can ignore `jsEnabled` value from `.finishLoading` action for this case.
            nextState = .viewing(settings, urlInfo)
        default:
            print("WebViewModelState: \(self.description) -> \(action.description) -> Error")
            throw Error.unexpectedStateForAction(self, action)
        }
        
        print("WebViewModelState: \(self.description) -> \(action.description) -> \(nextState.description)")
        return nextState
    }
}
