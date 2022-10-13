//
//  WebViewAction.swift
//  catowser
//
//  Created by Andrei Ermoshin on 8/27/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import CoreHttpKit
import JSPlugins

protocol Actionable {
    associatedtype Action
    associatedtype State
    func transition(on action: Action) throws -> State
}

typealias IPAddress = String

enum WebViewAction {
    case loadSite
    case loadNextLink(_ url: URL)
    case injectPlugins((any JSPluginsProgram)?)
    case fetchDoHStatus
    case checkDNResolvingSupport(Bool)
    case resolveDomainName(_ useDoH: Bool)
    case createRequestAnyway(IPAddress?)
    case loadWebView
    case finishLoading(URL, JavaScriptEvaluateble, _ jsEnabled: Bool)
    case startView(URLInfo)
    
    // middle actions
    
    case changeJavaScript(JavaScriptEvaluateble, Bool)
    case reload
    case goBack
    case goForward
    /// Similar to `resolveDomainName`
    case changeDoH(Bool)
}

extension WebViewAction: CustomStringConvertible {
    var description: String {
        switch self {
        case .loadSite:
            return "loadSite"
        case .loadNextLink(let nextURL):
#if DEBUG
            return "loadNextLink (\(nextURL.absoluteString))"
#else
            return "loadNextLink"
#endif
        case .reload:
            return "reload"
        case .injectPlugins:
            return "injectPlugins"
        case .fetchDoHStatus:
            return "fetchDoHStatus"
        case .checkDNResolvingSupport:
            return "checkDNResolvingSupport"
        case .resolveDomainName:
            return "resolveDomainName"
        case .createRequestAnyway:
            return "createRequestAnyway"
        case .loadWebView:
            return "loadWebView"
        case .finishLoading:
            return "finishLoading"
        case .startView:
            return "startView"
        case .changeJavaScript:
            return "changeJavaScript"
        case .goBack:
            return "goBack"
        case .goForward:
            return "goForward"
        case .changeDoH:
            return "changeDoH"
        }
    }
}
