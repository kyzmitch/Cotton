//
//  AuthChallenge.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 2/11/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import Alamofire
import Security

extension HttpKit {
    public func checkValidity(of serverTrust: SecTrust) -> Bool {
        let serverTrustPolicy = DefaultTrustEvaluator(validateHost: true)

        // When
        let result = Result { try serverTrustPolicy.evaluate(serverTrust, forHost: host) }

        // Then
        return result.isSuccess
    }
}
