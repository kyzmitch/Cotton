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
    case loadWebView(URLRequest)
    case finishLoading(URL, JavaScriptEvaluateble, _ jsEnabled: Bool)
    case startView
    
    // middle actions
    
    case changeJavaScript(JavaScriptEvaluateble, Bool)
    case reload
    case goBack
    case goForward
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
        case .injectPlugins(_):
            return "injectPlugins"
        case .fetchDoHStatus:
            return "fetchDoHStatus"
        case .checkDNResolvingSupport(_):
            return "checkDNResolvingSupport"
        case .resolveDomainName(_):
            return "resolveDomainName"
        case .createRequestAnyway:
            return "createRequestAnyway"
        case .loadWebView(_):
            return "loadWebView"
        case .finishLoading(_, _, _):
            return "finishLoading"
        case .startView:
            return "startView"
        case .changeJavaScript(_, _):
            return "changeJavaScript"
        case .goBack:
            return "goBack"
        case .goForward:
            return "goForward"
        }
    }
}
