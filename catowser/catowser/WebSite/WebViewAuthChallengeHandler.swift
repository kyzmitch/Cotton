//
//  WebViewAuthChallengeHandler.swift
//  catowser
//
//  Created by Andrei Ermoshin on 5/3/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import WebKit
import HttpKit
import Alamofire

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
    
    func solve(_ presentationController: UIViewController, completion: @escaping () -> Void) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        if let currentIPAddress = urlInfo.ipAddress, currentIPAddress == challenge.protectionSpace.host {
            handleServerTrust(serverTrust,
                              urlInfo.host.rawString,
                              presentationController,
                              completionHandler,
                              completion)
        } else {
            guard urlInfo.host.isSimilar(name: challenge.protectionSpace.host) else {
                // Here web site is trying to complete navigation
                // requests for supplementary hosts like analytics.
                // Obviously they're using own certificates to validate SSL
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
                           _ presentationController: UIViewController,
                           _ completionHandler: @escaping AuthHandler,
                           _ completion: @escaping () -> Void) {
        
        do {
            let evaluator: DefaultTrustEvaluator = .ipHostEvaluator()
            /**
             Even with disabled host validation for certificate
             the check fails, most likely it's still because
             requested host name is ip address and it is checked anyway
             with certificate host names list.
             So that, possibly by removing specific certificate from chain
             it will be possible to validate only by using root certificates.
             */
            
            var certificates = serverTrust.af.certificates
            print("\(host) has \(certificates.count) certificates")
            for cert in certificates {
                let string: String? = SecCertificateCopySubjectSummary(cert) as String?
                print("certificate info: \(string ?? "no info")")
            }
            _ = certificates.removeFirst()
            try serverTrust.af.setAnchorCertificates(certificates)
            try evaluator.evaluateWithRecovery(serverTrust, forHost: host)
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } catch {
            let msg = "Server trust validation failed.\n\n \(error.localizedDescription)\n\n\(host)"
            AlertPresenter.present(on: presentationController, message: msg)
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
            completion()
        }
    }
}
