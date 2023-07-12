//
//  DomainNativeAppChecker.swift
//  catowser
//
//  Created by Andrei Ermoshin on 03/06/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import CottonBase

final class DomainNativeAppChecker {
    /// Can't use hash set because need to check not full equality but partly equal case is also works
    private static let domains: [String] = ["instagram.com", "youtube.com"]
    /// App domain name in string
    let correspondingDomain: String

    init(host: Host) throws {
        for domain in DomainNativeAppChecker.domains where host.rawString.contains(domain) {
            correspondingDomain = domain
            return
        }

        struct NoAppError: Error {}
        throw NoAppError()
    }
}
