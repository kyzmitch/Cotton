//
//  HTMLVideoTag.swift
//  JSPlugins
//
//  Created by Andrey Ermoshin on 17/05/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

public struct HTMLVideoTag {
    public let src: URL
    public let poster: URL?
    public let name: String
    
    init?(srcURL: URL, posterURL: URL?, name: String) {
        src = srcURL
        poster = posterURL
        self.name = name
    }
}

extension HTMLVideoTag: VideoFileNameble {}

extension HTMLVideoTag: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        src = try container.decode(URL.self, forKey: .src)
        if let thumbnailURL = try? container.decodeIfPresent(URL.self, forKey: .poster) {
            poster = thumbnailURL
        } else {
            poster = nil
        }

        name = "\(UUID().uuidString)-decoded"
    }
}

extension HTMLVideoTag {
    enum CodingKeys: String, CodingKey {
        case src
        case poster
    }
}

extension HTMLVideoTag: Equatable {}
