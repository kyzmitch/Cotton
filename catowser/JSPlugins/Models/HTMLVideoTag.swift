//
//  HTMLVideoTag.swift
//  JSPlugins
//
//  Created by Andrey Ermoshin on 17/05/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

public struct HTMLVideoTag {
    let src: URL
    let poster: URL?
    
    init?(srcString: String, posterString: String?) {
        guard let srcURL = URL(string: srcString) else {
            return nil
        }
        
        src = srcURL
        if let posterURLString = posterString {
            poster = URL(string: posterURLString)
        } else {
            poster = nil
        }
    }
}

extension HTMLVideoTag: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        src = try container.decode(URL.self, forKey: .src)
        if let thumbnailURL = try? container.decodeIfPresent(URL.self, forKey: .poster) {
            poster = thumbnailURL
        } else {
            poster = nil
        }
    }
}

extension HTMLVideoTag {
    enum CodingKeys: String, CodingKey {
        case src
        case poster
    }
}

extension HTMLVideoTag: Equatable {}
