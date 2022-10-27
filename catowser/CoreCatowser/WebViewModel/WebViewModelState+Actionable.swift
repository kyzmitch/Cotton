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
        case (.viewing(let settings, let urlInfo),
              .loadNextLink(let url)):
            // DoH can be optimized here, if previous URLInfo had same host and resolved ip address
            let updatedURLInfo: URLInfo
            if url.hasIPHost {
                // swiftlint:disable:next force_unwrapping
                updatedURLInfo = urlInfo.withSimilar(url)!
            } else {
                // swiftlint:disable:next force_unwrapping
                updatedURLInfo = .init(url)!
            }
            nextState = .pendingPlugins(updatedURLInfo, settings)
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
        case (.waitingForNavigation(let settings, let urlInfo),
              .finishLoading(let finalURL, let pluginsSubject, let jsEnabled)):
            nextState = .finishingLoading(settings, finalURL, pluginsSubject, jsEnabled, urlInfo)
        case (.finishingLoading(let settings, _, _, _, _),
              .startView(let updatedURLInfo)):
            nextState = .viewing(settings, updatedURLInfo)
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
        case (.viewing(let settings, let urlData),
              .changeDoH(let enable)):
            // Handling is similar to when state is `pendingDoHStatus`
            // and action is `resolveDomainName`, because first need to
            // make sure that domain name supports DNS over HTTPs
            if enable {
                nextState = .checkingDNResolveSupport(urlData, settings)
            } else {
                // Need to reload web view anyway, because we don't know previus state of DoH
                // If ip address was used for URL, this reload would replace it with domain name as needed
                nextState = .creatingRequest(urlData, settings)
            }
        default:
#if TESTING
            print("WebViewModelState: \(self.description) -> \(action.description) -> Error")
#endif
            throw Error.unexpectedStateForAction(self, action)
        }
        
#if TESTING
        print("WebViewModelState: \(self.description) -> \(action.description) -> \(nextState.description)")
#endif
        return nextState
    }
}