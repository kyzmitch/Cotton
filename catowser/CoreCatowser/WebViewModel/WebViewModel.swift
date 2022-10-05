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
import WebKit

/// Simplified view actions for view use
public enum WebPageLoadingAction: Equatable {
    case idle
    case recreateView(Bool)
    case load(URLRequest)
    case reattachViewObservers
}

public protocol WebViewModel: AnyObject {
    // MARK: - main public methods
    
    func load()
    func reload()
    func goBack()
    func goForward()
    func finishLoading(_ newURL: URL, _ subject: JavaScriptEvaluateble)
    func decidePolicy(_ navigationAction: WKNavigationAction,
                      _ decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    func setJavaScript(_ subject: JavaScriptEvaluateble, _ enabled: Bool)
    
    // MARK: - public properties
    
    var nativeAppDomainNameString: String? { get }
    var configuration: WKWebViewConfiguration { get }
    var host: Host { get }
    var currentURL: URL? { get }
    var settings: Site.Settings { get }
    var urlInfo: URLInfo? { get }
    
    // MARK: - main state observers
    
    var rxWebPageState: MutableProperty<WebPageLoadingAction> { get }
    var combineWebPageState: CurrentValueSubject<WebPageLoadingAction, Never> { get }
    /// wrapped value for Published
    var webPageState: WebPageLoadingAction { get }
    var webPageStatePublisher: Published<WebPageLoadingAction>.Publisher { get }
}
