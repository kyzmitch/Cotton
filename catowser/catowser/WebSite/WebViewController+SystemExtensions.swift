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

private extension WebViewController {
    func handleAboutSchemeRedirect(_ mainDocumentURL: URL?,
                                   _ decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // This will handles about:blank from youtube
        // sometimes url can be unexpected
        // this one is when you tap on link on youtube
        
        if let mainURL = mainDocumentURL,
            let comparator = HostsComparator(urlInfo.url, mainURL) {
            if comparator.isPendingSame {
                decisionHandler(.allow)
            } else {
                decisionHandler(.cancel)
            }
        } else {
            // don't show progress for requests to about scheme
            decisionHandler(.allow)
        }
    }
    
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
    
    func handleUnwantedRedirect(_ url: URL,
                                _ decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) -> Bool {
        guard let pendingHost = url.host else {
            decisionHandler(.cancel)
            return true
        }
        let unwantedRedirect: Bool
        if url.hasIPHost {
            let sameIPaddress = pendingHost == urlInfo.ipAddress
            unwantedRedirect = !sameIPaddress
        } else {
            let comparator = HostsComparator(urlInfo.host, pendingHost)
            unwantedRedirect = comparator.shouldCancelRedirect
        }
        if unwantedRedirect {
            decisionHandler(.cancel)
            return true
        }
        
        return false
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
        
        switch url.scheme {
        case "about":
            let mainURL = navigationAction.request.mainDocumentURL
            handleAboutSchemeRedirect(mainURL, decisionHandler)
            return
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
        
        guard !handleUnwantedRedirect(url, decisionHandler) else {
            return
        }

        guard !handleNativeAppSchemeRedirect(url, decisionHandler) else {
            return
        }

        switch url.scheme {
        case "http", "https":
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
        InMemoryDomainSearchProvider.shared.rememberDomain(name: urlInfo.host)
        
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
            case (.none, .none):
                print("failed to take a screenshot")
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Fail to load URL request: \(error.localizedDescription)")
        externalNavigationDelegate?.showProgress(false)
    }
    
    func webView(_ webView: WKWebView,
                 didReceive challenge: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        let oldHost = urlInfo.host
        let host = challenge.protectionSpace.host
        guard host.contains(oldHost)
            || oldHost.contains(host)
            || host == urlInfo.host else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        if serverTrust.checkValidity(ofHost: oldHost) {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            // Show a UI here warning the user the server credentials are
            // invalid, and cancel the load.
            completionHandler(.cancelAuthenticationChallenge, nil)
            externalNavigationDelegate?.showProgress(false)
        }
    }
}
