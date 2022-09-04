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
    case injectPlugins(JSPluginsProgram?)
    case fetchDoHStatus
    case checkDNResolvingSupport(Bool)
    case resolveDomainName(_ useDoH: Bool)
    case createRequestAnyway(URL)
    case loadWebView(URLRequest)
    case finishLoading(URL, JavaScriptEvaluateble, _ jsEnabled: Bool)
    case startView
    
    // middle actions
    
    case changeJavaScript(JavaScriptEvaluateble, Bool)
}
