//
//  TagsSiteDataSource.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/22/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import JSPlugins

enum TagsSiteDataSource {
    case instagram([InstagramVideoNode])
    case t4(T4Video)
    
    var itemsCount: Int {
        switch self {
        case .instagram(let nodes):
            return nodes.count
        case .t4:
            return 1
        }
    }
}

extension TagsSiteDataSource: Equatable {
    
}
