//
//  DomainsHistory.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 11/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

/// Interface for domain checks
///
/// TODO: need to divide on two protocols because each method used by different classes
public protocol DomainsHistory {
    func rememberDomain(name: String)
    func domainNames(whereURLContains filter: String) -> [String]
}
