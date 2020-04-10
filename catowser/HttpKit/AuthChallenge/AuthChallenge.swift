//
//  AuthChallenge.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 2/11/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import Security

extension SecTrust {
    public func checkValidity(ofHost host: String) -> Bool {
        // re-implement with using Alamofire 5.x
        // swiftlint:disable:next line_length
        // https://alamofire.github.io/Alamofire/Classes/DefaultTrustEvaluator.html#/s:9Alamofire21ServerTrustEvaluatingP8evaluate_7forHostySo03SecC3Refa_SStKF
        // swiftlint:disable:next line_length
        // https://github.com/Alamofire/Alamofire/blob/6fc79382515e26a2328ab24c75a777128d234248/Source/ServerTrustEvaluation.swift
        let serverTrustPolicy = WildcardHostTrustEvaluator(validateHost: true)
        guard let kitHost = HttpKit.Host(rawValue: host) else {
            return serverTrustPolicy.evaluate(self, forHost: host)
        }
        
        let originalCheck = serverTrustPolicy.evaluate(self, forHost: host)
        let wildcardName = kitHost.wildcardName
        let wildcardCheck = serverTrustPolicy.evaluate(self, forHost: wildcardName)
        let wwwName = kitHost.wwwName
        let wwwCheck = serverTrustPolicy.evaluate(self, forHost: wwwName)
        return wildcardCheck || originalCheck || wwwCheck
    }
}
