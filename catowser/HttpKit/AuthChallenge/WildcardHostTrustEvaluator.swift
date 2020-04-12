//
//  WildcardHostTrustEvaluator.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 3/29/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation

class WildcardHostTrustEvaluator: DefaultTrustEvaluator {
    override func evaluate(_ trust: SecTrust, forHost host: String) -> Bool {
        // https://developer.apple.com/library/archive/technotes/tn2232/_index.html
        // The DNS name in the certificate might be a wildcard name, for example, "*.apple.com".
        // but `host` parameter could be specific address like "m.apple.com"
        // so that, it's required to convert it to wildcard name before check
        
        let policy = SecPolicyCreateSSL(true, validateHost ? host as CFString : nil)
        SecTrustSetPolicies(trust, policy)
        
        print("Checking secTrut for: \(host)")
        return trust.isValid
    }
}
