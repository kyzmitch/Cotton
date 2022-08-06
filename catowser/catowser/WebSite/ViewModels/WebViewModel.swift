//
//  WebViewModel.swift
//  catowser
//
//  Created by Andrei Ermoshin on 7/26/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import CoreHttpKit
import JSPlugins
import FeaturesFlagsKit
import ReactiveSwift
import Combine

protocol Actionable {
    associatedtype Action
    associatedtype State
    func transition(on action: Action) throws -> State
}

typealias IPAddress = String

enum WebViewAction {
    case loadUrl(_ url: URL)
    case loadSite(_ site: Site)
    case injectPlugins([JavaScriptPlugin]?)
    case fetchDoHStatus
    case checkDNResolvingSupport(Bool)
    case resolveDomainName(_ useDoH: Bool)
    case createRequestAnyway(URL)
    case loadWebView(URLRequest)
    case finishLoading
}

enum WebViewState {
    case waitingForURL
    case pendingPlugins(URLData)
    case injectingPlugins([JavaScriptPlugin], URLData)
    case pendingDoHStatus(URLData)
    case checkingDNResolveSupport(URLData)
    case resolvingDN(URLData)
    case creatingRequest(URL)
    case updatingWebView(URLRequest)
    
    enum Error: LocalizedError {
        case unexpectedStateForAction
        
    }
}

extension WebViewState: Actionable {
    typealias Action = WebViewAction
    typealias State = Self
    
    // swiftlint:disable:next cyclomatic_complexity
    func transition(on action: Action) throws -> State {
        switch (self, action) {
        case (.waitingForURL, .loadUrl(let url)):
            return .pendingPlugins(.url(url))
        case (.waitingForURL, .loadSite(let site)):
            return .pendingPlugins(.info(site.urlInfo))
        case (.pendingPlugins(let urlData), .injectPlugins(let plugins)):
            if let plugins = plugins {
                return .injectingPlugins(plugins, urlData)
            } else {
                return .pendingDoHStatus(urlData)
            }
        case (.injectingPlugins(_, let urlData), .fetchDoHStatus):
            return .pendingDoHStatus(urlData)
        case (.pendingPlugins(let urlData), .fetchDoHStatus):
            return .pendingDoHStatus(urlData)
        case (.pendingDoHStatus(let urlData), .resolveDomainName(let useDoH)):
            if useDoH {
                return .checkingDNResolveSupport(urlData)
            } else {
                return .creatingRequest(urlData.platformURL)
            }
        case (.checkingDNResolveSupport(let urlData), .checkDNResolvingSupport(let resolveNeeded)):
            if resolveNeeded {
                return .resolvingDN(urlData)
            } else {
                return .creatingRequest(urlData.platformURL)
            }
        case (.resolvingDN, .createRequestAnyway(let url)):
            return .creatingRequest(url)
        case (.creatingRequest, .loadWebView(let request)):
            return .updatingWebView(request)
        case (.updatingWebView, .finishLoading):
            return .waitingForURL
        default:
            throw Error.unexpectedStateForAction
        }
    }
}

enum WebPageLoadingState {
    case idle
    case load(URLRequest)
}

protocol WebViewModel: AnyObject {
    func load(url: URL)
    func load(site: Site)
    func didFinishLoading()
    
    var rxWebPageState: MutableProperty<WebPageLoadingState> { get }
    var combineWebPageState: CurrentValueSubject<WebPageLoadingState, Never> { get }
    /// wrapped value for Published
    var webPageState: WebPageLoadingState { get }
    var webPageStatePublisher: Published<WebPageLoadingState>.Publisher { get }
}
