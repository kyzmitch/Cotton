//
//  WebViewAuthChallengeHandler.swift
//  catowser
//
//  Created by Andrei Ermoshin on 5/3/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import WebKit
import HttpKit

final class WebViewAuthChallengeHandler {
    typealias AuthHandler = (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    
    let urlInfo: HttpKit.URLIpInfo
    let challenge: URLAuthenticationChallenge
    let completionHandler: AuthHandler
    let webView: WKWebView
    
    init(_ urlInfo: HttpKit.URLIpInfo,
         _ webView: WKWebView,
         _ challenge: URLAuthenticationChallenge,
         _ completionHandler: @escaping AuthHandler) {
        self.urlInfo = urlInfo
        self.webView = webView
        self.challenge = challenge
        self.completionHandler = completionHandler
    }
    
    func solve(completion: @escaping () -> Void) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        guard let nextUrl = webView.url else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        if let currentIPAddress = urlInfo.ipAddress, nextUrl.hasIPHost {
            if currentIPAddress == challenge.protectionSpace.host {
                handleServerTrust(serverTrust, urlInfo.host.rawValue, completionHandler, completion)
            } else {
                completionHandler(.performDefaultHandling, nil)
            }
        } else {
            guard urlInfo.host.isSimilar(with: challenge.protectionSpace.host) else {
                completionHandler(.performDefaultHandling, nil)
                return
            }

            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        }
    }
}

private extension WebViewAuthChallengeHandler {
    func handleServerTrust(_ serverTrust: SecTrust,
                           _ host: String,
                           _ completionHandler: @escaping AuthHandler,
                           _ completion: @escaping () -> Void) {
        if serverTrust.checkValidity(ofHost: host) {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            // Show a UI here warning the user the server credentials are
            // invalid, and cancel the load.
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
            completion()
        }
    }
}
