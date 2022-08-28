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
enum WebPageLoadingAction {
    case idle
    case recreateView(Bool)
    case load(URLRequest)
    case reattachViewObservers
}

protocol WebViewModel: AnyObject {
    // MARK: - main public methods
    
    func load(url: URL)
    func load(site: Site)
    func finishLoading()
    func enableJSPlugins(_ subject: JavaScriptEvaluateble, _ enable: Bool)
    
    // MARK: - Not main methods which could be refactored
    
    func setJavaScript(enabled: Bool)
    var nativeAppDomainNameString: String? { get }
    func decidePolicyFor(_ navigationAction: WKNavigationAction,
                         _ decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    func finishNavigation(_ newURL: URL)
    
    // MARK: - public properties
    
    var configuration: WKWebViewConfiguration { get }
    var host: Host? { get }
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
