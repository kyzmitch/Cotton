//
//  WebViewController+SystemExtensions.swift
//  catowser
//
//  Created by Andrei Ermoshin on 3/20/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import WebKit
import CoreBrowser
import HttpKit

private extension WebViewController {
    func handleNativeAppSchemeRedirect(_ url: URL,
                                       _ decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) -> Bool {
        let isSameHost = urlInfo.sameHost(with: url)
        guard isSameHost else {
            return false
        }
        guard let checker = try? DomainNativeAppChecker(host: urlInfo.host) else {
            return false
        }
        externalNavigationDelegate?.didOpenSiteWith(appName: checker.correspondingDomain)

        let ignoreAppRawValue = WKNavigationActionPolicy.allow.rawValue + 2
        guard WKNavigationActionPolicy(rawValue: ignoreAppRawValue) != nil else {
            return false
        }
        // swiftlint:disable:next force_unwrapping
        decisionHandler(WKNavigationActionPolicy(rawValue: ignoreAppRawValue)!)
        return true
    }
}

// MARK: - WKUIDelegate

extension WebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        return nil
    }
}

// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
#if false
        print("navAction: \(navigationAction.navigationType.debugDescription) \(url)")
#endif
        
        switch url.scheme {
        case "tel", "facetime", "facetime-audio", "mailto":
            UIApplication.shared.open(url, options: [:])
            decisionHandler(.cancel)
            return
        default:
            break
        }

        guard !url.isAppleMapsURL else {
            UIApplication.shared.open(url, options: [:])
            decisionHandler(.cancel)
            return
        }

        guard !url.isStoreURL else {
            UIApplication.shared.open(url, options: [:])
            decisionHandler(.cancel)
            return
        }

        guard !handleNativeAppSchemeRedirect(url, decisionHandler) else {
            return
        }

        switch url.scheme {
        case "http", "https":
            decisionHandler(.allow)
        case "about":
            decisionHandler(.allow)
        default:
            decisionHandler(.cancel)
        }
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        externalNavigationDelegate?.showProgress(true)
        
        guard let webViewUrl = webView.url else {
            print("web view without url")
            return
        }
        
        if webViewUrl.hasIPHost {
            urlInfo.updateURLForSameIP(url: webViewUrl)
        } else {
            urlInfo.updateURLForSameHost(url: webViewUrl)
        }
        
        guard let site = Site(url: urlInfo.domainURL) else {
            assertionFailure("failed create site from URL")
            return
        }
        
        // you must inject re-enable plugins even if web view loaded page from same Host
        // and even if ip address is used instead of domain name
        pluginsFacade?.enablePlugins(for: webView, with: urlInfo.host)
        InMemoryDomainSearchProvider.shared.remember(domainName: urlInfo.host)
        
        do {
            try TabsListManager.shared.replaceSelected(tabContent: .site(site))
        } catch {
            print("\(#function) - failed to replace current tab")
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        externalNavigationDelegate?.showProgress(false)
        
        let snapshotConfig = WKSnapshotConfiguration()
        let w = webView.bounds.size.width
        let h = webView.bounds.size.height
        snapshotConfig.rect = CGRect(x: 0, y: 0, width: w, height: h)
        snapshotConfig.snapshotWidth = 256
        webView.takeSnapshot(with: snapshotConfig) { [weak self] (image, error) in
            switch (image, error) {
            case (_, let err?):
                print("failed to take a screenshot \(err)")
            case (let img?, _):
                self?.externalNavigationDelegate?.updateTabPreview(img)
            default:
                print("failed to take a screenshot")
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Error occured during a committed main frame: \(error.localizedDescription)")
        externalNavigationDelegate?.showProgress(false)
    }
    
    func webView(_ webView: WKWebView,
                 didReceive challenge: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let handler = WebViewAuthChallengeHandler(urlInfo, webView, challenge, completionHandler)
        handler.solve(self) { [weak self] in
            self?.externalNavigationDelegate?.showProgress(false)
        }
    }
    
    func webView(_ webView: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {
        print("Error occured while starting to load data: \(error.localizedDescription)")
        externalNavigationDelegate?.showProgress(false)
        let handler = WebViewLoadingErrorHandler(error, webView)
        handler.recover(self)
    }
}

extension WKNavigationType: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .linkActivated:
            return "linkActivated"
        case .formSubmitted:
            return "formSubmitted"
        case .backForward:
            return "backForward"
        case .reload:
            return "reload"
        case .formResubmitted:
            return "formResubmitted"
        case .other:
            return "other"
        @unknown default:
            return "default \(rawValue)"
        }
    }
}
