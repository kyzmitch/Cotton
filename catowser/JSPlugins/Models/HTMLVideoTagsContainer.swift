//
//  HTMLVideoTagsContainer.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 04/05/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

public struct HTMLVideoTagsContainer {
    public let videoURLs: [URL]
    init(html: String) throws {
        throw CottonError.noTags
    }
}

extension HTMLVideoTagsContainer {
    enum CottonError: Error {
        case noTags
    }
}
