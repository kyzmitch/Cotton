//
//  TagsSiteDataSource.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/22/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import CottonPlugins

enum TagsSiteDataSource {
    case instagram([InstagramVideoNode])
    case htmlVideos([HTMLVideoTag])
    
    var itemsCount: Int {
        switch self {
        case .instagram(let nodes):
            return nodes.count
        case .htmlVideos(let tags):
            return tags.count
        }
    }
}

extension TagsSiteDataSource: Equatable {}
