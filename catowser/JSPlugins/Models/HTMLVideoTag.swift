//
//  HTMLVideoTag.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 26/03/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

public struct HTMLVideoTag: Decodable {
    let videoUrl: URL
    let posterUrl: URL
}

extension HTMLVideoTag {
    enum CodingKeys: String, CodingKey {
        case videoUrl = "src"
        case posterUrl = "poster"
    }
}
