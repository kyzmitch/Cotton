//
//  WebViewAction.swift
//  CottonViewModels
//
//  Created by Andrei Ermoshin on 8/27/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation
import CottonBase
import CottonPlugins
import ViewModelKit

public typealias IPAddress = String

public enum WebViewAction: Sendable, ViewModelAction {
    case loadSite
    case resetToSite(Site)
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

    /// Representative cases for `ViewModelAction` / `CaseIterable`.
    public static var allCases: [WebViewAction] {
        // swiftlint:disable force_unwrapping
        let url = URL(string: "https://example.com")!
        let urlInfo = URLInfo(url)!
        let site = Site(
            urlInfo: urlInfo,
            settings: .init(
                isPrivate: false,
                blockPopups: false,
                isJSEnabled: false,
                canLoadPlugins: false
            ),
            faviconData: nil,
            searchSuggestion: nil,
            userSpecifiedTitle: nil
        )
        let jsSubject = WebViewActionAllCasesJSSubject()
        // swiftlint:enable force_unwrapping
        return [
            .loadSite,
            .resetToSite(site),
            .loadNextLink(url),
            .injectPlugins(nil),
            .fetchDoHStatus,
            .checkDNResolvingSupport(false),
            .resolveDomainName(false),
            .createRequestAnyway(nil),
            .loadWebView,
            .finishLoading(url, jsSubject, false),
            .startView(urlInfo),
            .changeJavaScript(jsSubject, false),
            .reload,
            .goBack,
            .goForward,
            .changeDoH(false)
        ]
    }
}

/// Placeholder subject only for `WebViewAction.allCases`.
@MainActor
private final class WebViewActionAllCasesJSSubject: JavaScriptEvaluateble, Sendable {
    func evaluateJavaScriptV2(
        _ javaScriptString: String,
        completionHandler: (@MainActor @Sendable (Any?, (any Error)?) -> Void)?
    ) {
        completionHandler?(nil, nil)
    }

    func evaluateJavaScriptV1(
        _ javaScriptString: String,
        completionHandler: ((Any?, Error?) -> Void)?
    ) {
        completionHandler?(nil, nil)
    }
}

extension WebViewAction: CustomStringConvertible {
    public var description: String {
        switch self {
        case .loadSite:
            return "loadSite"
        case .resetToSite(let site):
            return "resetToSite (\(site.urlInfo.platformURL.absoluteString)"
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
