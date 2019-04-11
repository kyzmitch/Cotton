//
//  DomainsHistory.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 11/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

public protocol DomainsHistory {
    func rememberDomain(name: String)
    func domainNames(whereURLContains filter: String) -> [String]
}
