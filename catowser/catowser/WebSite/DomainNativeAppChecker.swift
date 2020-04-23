//
//  DomainNativeAppChecker.swift
//  catowser
//
//  Created by Andrei Ermoshin on 03/06/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import HttpKit

final class DomainNativeAppChecker {
    private static let domains: [String] = ["instagram.com", "youtube.com"]
    let correspondingDomain: String

    init(host: HttpKit.Host) throws {
        for domain in DomainNativeAppChecker.domains {
            if host.rawValue.contains(domain) {
                correspondingDomain = domain
                return
            }
        }

        struct NoAppError: Error {}
        throw NoAppError()
    }
}
