//
//  WebViewModel.swift
//  catowser
//
//  Created by Andrei Ermoshin on 7/26/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import CottonBase
import CottonPlugins
import FeaturesFlagsKit
import Combine
import WebKit

/// Simplified view actions for view use
public enum WebPageLoadingAction: Equatable {
    //
    case recreateView(Bool)
    case load(URLRequest)
    case reattachViewObservers
    case openApp(URL)
}

/// Interface for system's type `WKNavigationAction` from WebKit framework to be able to mock it
public protocol NavigationActionable: AnyObject {
    var navigationType: WKNavigationType { get }
    var request: URLRequest { get }
}

@MainActor
public protocol WebViewModel: AnyObject {
    // MARK: - main public methods
    
    func load() async
    func reset(_ site: Site) async
    func reload() async
    func goBack() async
    func goForward() async
    func finishLoading(_ newURL: URL, _ subject: JavaScriptEvaluateble) async
    func decidePolicy(_ navigationAction: NavigationActionable,
                      _ decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) async
    func setJavaScript(_ subject: JavaScriptEvaluateble, _ enabled: Bool) async
    func setDoH(_ enabled: Bool) async
    
    // MARK: - public properties
    
    var nativeAppDomainNameString: String? { get }
    var configuration: WKWebViewConfiguration { get }
    var host: CottonBase.Host { get }
    var currentURL: URL? { get }
    var settings: Site.Settings { get }
    var urlInfo: URLInfo { get }
    /// Only for SwiftUI check to avoid handling of view updates
    var isResetable: Bool { get }
    
    // MARK: - main state observers

    /// wrapped value for Published
    var webPageState: WebPageLoadingAction { get }
    var webPageStatePublisher: Published<WebPageLoadingAction>.Publisher { get }
}
