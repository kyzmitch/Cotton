//
//  DomainsHistory.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 11/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import CottonBase
import AutoMockable

public protocol KnownDomainsSource: AutoMockable {
    func domainNames(whereURLContains filter: String) async -> [String]
}

/// Interface for domain checks
public protocol DomainsHistory {
    func remember(host: CottonBase.Host) async
}
