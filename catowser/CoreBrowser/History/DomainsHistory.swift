//
//  DomainsHistory.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 11/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import CoreHttpKit

/// Interface for domain checks
public protocol DomainsHistory {
    func remember(host: CoreHttpKit.Host)
    func domainNames(whereURLContains filter: String) -> [String]
}
