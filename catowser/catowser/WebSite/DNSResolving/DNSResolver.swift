//
//  DNSResolver.swift
//  catowser
//
//  Created by Andrei Ermoshin on 7/29/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation

final class DNSResolver<Strategy> where Strategy: DNSResolvingStrategy {
    let strategy: Strategy
    
    init(_ strategy: Strategy) {
        self.strategy = strategy
    }
}
