//
//  DomainsHistory.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 11/04/2019.
//  Copyright © 2019 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import CottonBase
import AutoMockable

/// Interface for known domain checks. Has to have async methods because actual class is a global actor.
///
/// Can be sendable because implementation is a global actor.
public protocol KnownDomainsSource: AutoMockable, Actor {
    func domainNames(whereURLContains filter: String) async -> [String]
}

/// Interface for domain checks. Has to have async methods because actual class is a global actor.
///
/// Can be sendable because implementation is a global actor.
public protocol DomainsHistory: Actor {
    func remember(host: CottonBase.Host) async
}
