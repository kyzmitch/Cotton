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
    
    func handleServerTrust(_ serverTrust: SecTrust,
                           host: String,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if serverTrust.checkValidity(ofHost: host) {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            // Show a UI here warning the user the server credentials are
            // invalid, and cancel the load.
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
            externalNavigationDelegate?.showProgress(false)
        }
    }
    
    func checkIfWebContentProcessHasCrashed(_ webView: WKWebView, error: NSError) -> Bool {
        if error.code == WKError.webContentProcessTerminated.rawValue && error.domain == "WebKitErrorDomain" {
            print("WebContent process has crashed. Trying to reload to restart it.")
            webView.reload()
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
        let realHost = challenge.protectionSpace.host
        guard let nextUrl = webView.url else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        if let currentIPAddress = urlInfo.ipAddress, nextUrl.hasIPHost {
            if currentIPAddress == realHost {
                handleServerTrust(serverTrust,
                                  host: urlInfo.host.rawValue,
                                  completionHandler: completionHandler)
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
    
    func webView(_ webView: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {
        print("Provisional fail: \(error.localizedDescription)")
        let error = error as NSError
        if checkIfWebContentProcessHasCrashed(webView, error: error) {
            return
        }
        /**
        Called when an error occurs while the web view is loading content.
        In our case it happens on auth challenge fail when entered domain name doesn't match with one
        in server SSL certificate or when ip address was used for DNS over HTTPS and it can't
        be equal with domain names from SSL certificate.
        */
        if let url = error.userInfo[NSURLErrorFailingURLErrorKey] as? URL {
            // ErrorPageHelper(certStore: profile.certStore).loadPage(error, forUrl: url, inWebView: webView)
        }
    }
}
