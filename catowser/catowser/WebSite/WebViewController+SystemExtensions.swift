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
    func handleNavigationCommit(_ wkView: WKWebView) {
        guard let webViewUrl = wkView.url else {
            print("web view without url")
            return
        }

        guard let site = Site(url: webViewUrl) else {
            assertionFailure("failed create site from URL")
            return
        }
        
        // you must inject re-enable plugins even if web view loaded page from same Host
        
        if !site.url.hasIPHost {
            pluginsFacade?.enablePlugins(for: wkView, with: site.host)
            InMemoryDomainSearchProvider.shared.rememberDomain(name: site.host)
        }
        
        do {
            try TabsListManager.shared.replaceSelected(tabContent: .site(site))
        } catch {
            print("\(#function) - failed to replace current tab")
        }
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

        if !urlInfo.url.hasIPHost,
            !url.hasIPHost,
            HostsComparator(urlInfo.url, url)?.shouldCancelRedirect ?? false {
            decisionHandler(.cancel)
            return
        }
        
        if url.scheme == "about" {
            // This will handle about:blank from youtube.
            // sometimes url can be unexpected
            // this one is when you tap on some youtube video
            // when you was browsing youtube
            
            if let mainURL = navigationAction.request.mainDocumentURL,
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
            return
        }
        
        if url.scheme == "tel" || url.scheme == "facetime" || url.scheme == "facetime-audio" {
            UIApplication.shared.open(url, options: [:])
            decisionHandler(.cancel)
            return
        }

        if url.isAppleMapsURL {
            UIApplication.shared.open(url, options: [:])
            decisionHandler(.cancel)
            return
        }

        if url.isStoreURL {
            UIApplication.shared.open(url, options: [:])
            decisionHandler(.cancel)
            return
        }

        if url.scheme == "mailto" {
            UIApplication.shared.open(url, options: [:])
            decisionHandler(.cancel)
            return
        }

        if !url.hasIPHost,
            let newHost = url.host,
            let checker = try? DomainNativeAppChecker(url: newHost) {
            externalNavigationDelegate?.didOpenSiteWith(appName: checker.correspondingDomain)

            let ignoreAppRawValue = WKNavigationActionPolicy.allow.rawValue + 2
            guard WKNavigationActionPolicy(rawValue: ignoreAppRawValue) != nil else {
                decisionHandler(.allow)
                return
            }
            // swiftlint:disable:next force_unwrapping
            decisionHandler(WKNavigationActionPolicy(rawValue: ignoreAppRawValue)!)
            return
        }

        if ["http", "https"].contains(url.scheme) {
            decisionHandler(.allow)
            return
        }

        decisionHandler(.cancel)
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        externalNavigationDelegate?.showProgress(true)
        handleNavigationCommit(webView)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        externalNavigationDelegate?.showProgress(false)
        if !urlInfo.url.hasIPHost, let actualHost = urlInfo.url.host {
            pluginsFacade?.enablePlugins(for: webView, with: actualHost)
        }
        
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
        guard let oldHost = urlInfo.url.host else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        let host = challenge.protectionSpace.host
        guard host.contains(oldHost)
            || oldHost.contains(host)
            || host == urlInfo.ipAddress else {
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
        }
    }
}
