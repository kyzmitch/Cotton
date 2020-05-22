//
//  VideoFileNameble.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 29/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

public protocol VideoFileNameble {
    var name: String { get }
    /// Used to provide same interface as `Downloadable` protocol  from HttpKit
    var fileName: String { get }
}

public extension VideoFileNameble {
    var fileName: String {
        let prefix: String
        if let i = name.firstIndex(where: { $0 == "\n" }) {
            prefix = String(name.prefix(upTo: i))
        } else {
            prefix = name
        }
        return "\(prefix).mp4"
    }
}
