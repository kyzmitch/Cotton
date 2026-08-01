//
//  WebViewStateTransitioning.swift
//  CottonViewModels
//
//  Copyright © 2026 Cotton (Catowser). All rights reserved.
//

import Foundation
import CottonBase
import CottonPlugins
import ViewModelKit

/// Async transition strategy for WebView domain state.
///
/// Owns the legal `(state, action) → nextState` graph. Pipeline side effects
/// (plugins inject, DNS, loading emits) run in `WebViewModelImpl` after each
/// successful `sendAction`, which may issue follow-up actions — intermediate
/// states stay observable on `statePublisher`.
public struct WebViewStateTransitioning<C: WebViewStateContext>: StateTransitioning {
    public typealias State = WebViewModelState<C>

    public init() {}

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    @MainActor public func transition(
        from state: State,
        on action: State.Action,
        with context: State.Context?
    ) async throws -> State {
        _ = context
        let nextState: State
        switch (state, action) {
        case (.pendingLoad, .loadSite):
            /// Nothing to load actually, waiting for `resetToSite` action
            return state
        case (.initialized(let site),
              .loadSite):
            nextState = .pendingPlugins(site.urlInfo, site.settings)
        case (.viewing(let settings, let urlInfo),
              .loadNextLink(let url)):
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
                nextState = state
            } else {
                let jsSettings = settings.withChanged(javaScriptEnabled: enabled)
                nextState = .updatingJS(jsSettings, subject, urlInfo)
            }
        case (.updatingJS(let settings, _, let urlInfo),
              .finishLoading):
            nextState = .viewing(settings, urlInfo)
        case (.viewing(let settings, let urlData),
              .changeDoH(let enable)):
            if enable {
                nextState = .checkingDNResolveSupport(urlData, settings)
            } else {
                nextState = .creatingRequest(urlData, settings)
            }
        case (.viewing, .resetToSite(let site)):
            nextState = .initialized(site)
        case (.waitingForNavigation, .resetToSite(let site)):
            nextState = .initialized(site)
        case (.pendingLoad, .resetToSite(let site)):
            nextState = .initialized(site)
        case (.waitingForNavigation(let settings, let uRLInfo),
              .reload):
            nextState = .waitingForNavigation(settings, uRLInfo)
        case (.waitingForNavigation(let settings, let uRLInfo),
              .goBack):
            nextState = .waitingForNavigation(settings, uRLInfo)
        case (.waitingForNavigation(let settings, let uRLInfo),
              .goForward):
            nextState = .waitingForNavigation(settings, uRLInfo)
        default:
            throw State.Error.unexpectedStateForAction(state, action)
        }
        return nextState
    }
}
