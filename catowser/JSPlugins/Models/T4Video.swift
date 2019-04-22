//
//  T4Video.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 22/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

public struct T4Video: Decodable {
    let resolution: Resolution?
    let videoURL: URL

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: VideoCodingKeys.self)
        videoURL = try container.decode(URL.self, forKey: .token)
        if let resolutionKey = decoder.codingPath.last?.stringValue {
            resolution = Resolution(rawValue: resolutionKey)
        } else {
            resolution = nil
        }

    }
}

extension T4Video {
    enum VideoCodingKeys: String, CodingKey {
        case token
    }

    enum Resolution: String, CodingKey {
        case p240 = "240"
        case p360 = "360"
        case p480 = "480"
        case p720 = "720"
        case p1080 = "1080"
    }
}

