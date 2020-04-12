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
        /**
         The DNS name in the certificate might be a wildcard name, for example, "*.apple.com".
         but `host` parameter could be specific address like "m.apple.com"
         so that, it's required to convert it to wildcard name before check
         */
        
        /**
         If server trust evaluation fails because the server's DNS name does not match the DNS name in the certificate,
         you can work around the failure by overriding the DNS name in the trust object.
         To do this, call SecPolicyCreateSSL to create a new policy object with the correct server name
         and then call SecTrustSetPolicies to apply it to the trust object.
         */
        
        /**
         Typically you would expect to find this DNS name in the subject's Common Name field,
         but it can also be in a Subject Alternative Name extension. If a name is present in
         the Subject Alternative Name extension, it takes priority over the Common Name.
         */
        
        /**
         https://support.apple.com/en-us/HT210176
         TLS server certificates must present the DNS name of the server in the Subject Alternative Name extension
         of the certificate. DNS names in the CommonName of a certificate are no longer trusted.
         */
        
        // https://developer.apple.com/documentation/security/certificate_key_and_trust_services/trust/configuring_a_trust
        
        let policy: SecPolicy
        if validateHost {
            #if true
            let cfHost: CFString = host as CFString
            policy = SecPolicyCreateSSL(true, cfHost)
            let status = SecTrustSetPolicies(trust, policy)
            if status == errSecSuccess {
                print("SecTrut checking for: \(host)")
            } else {
                print("SecTrut failed to update host policy for: \(host) \(status)")
            }
            #else
            let properties: CFDictionary = [kSecPolicyName as String: host] as CFDictionary
            let identifier: CFTypeRef = CFStr
            guard let propertyPolicy = SecPolicyCreateWithProperties(nil, properties) else {
                return trust.isValid
            }
            policy = propertyPolicy
            #endif
        }
        
        return trust.isValid
    }
}
