//
//  WebViewAuthChallengeHandler.swift
//  catowser
//
//  Created by Andrei Ermoshin on 5/3/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import WebKit
import CoreHttpKit
import Alamofire

final class WebViewAuthChallengeHandler {
    let urlInfo: URLInfo
    let challenge: URLAuthenticationChallenge
    let completionHandler: AuthHandler
    
    init(_ urlInfo: URLInfo,
         _ challenge: URLAuthenticationChallenge,
         _ completionHandler: @escaping AuthHandler) {
        self.urlInfo = urlInfo
        self.challenge = challenge
        self.completionHandler = completionHandler
    }
    
    func solve(errorHandler: @escaping () -> Void) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        let possibleIPAddress = urlInfo.ipAddressString
        let rawDomainName = urlInfo.domainName.rawString
        let challengeHost = challenge.protectionSpace.host
#if DEBUG
        print("""
handleServerTrust:
domainName[\(rawDomainName)],
challengeHost[\(challengeHost)],
ip[\(possibleIPAddress ?? "none")]
"""
        )
#endif
        if let ipAddress = possibleIPAddress, ipAddress == challenge.protectionSpace.host {
            handleServerTrust(serverTrust,
                              rawDomainName,
                              completionHandler,
                              errorHandler)
        } else if !urlInfo.host().isSimilar(name: challenge.protectionSpace.host) {
            // Here web site is trying to complete navigation
            // requests for supplementary hosts like analytics.
            // Obviously they're using own certificates to validate SSL
            completionHandler(.performDefaultHandling, nil)
            return
        } else {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        }
    }
}

private extension WebViewAuthChallengeHandler {
    func handleServerTrust(_ serverTrust: SecTrust,
                           _ host: String,
                           _ completionHandler: @escaping AuthHandler,
                           _ errorHandler: @escaping () -> Void) {
        
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
#if DEBUG
            print("handleServerTrust: domain name - \(host) has \(certificates.count) certificates")
            for cert in certificates {
                let string: String? = SecCertificateCopySubjectSummary(cert) as String?
                print("handleServerTrust: certificate[\(string ?? "none")]")
            }
#endif
            _ = certificates.removeFirst()
            try serverTrust.af.setAnchorCertificates(certificates)
            try evaluator.evaluateWithRecovery(serverTrust, forHost: host)
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } catch {
            let msg = "handleServerTrust: validation failed.\n\n \(error.localizedDescription)\n\n\(host)"
            print("Error: \(msg)")
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
            errorHandler()
        }
    }
}
