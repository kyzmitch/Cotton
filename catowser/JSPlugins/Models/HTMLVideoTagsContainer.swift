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
        guard html.count > 0 else {
            throw CottonError.emptyHtml
        }
        
        let tagsStartIndexes = html.indices(of: "<video")
        let tagsEndIndexes = html.indices(of: "</video>")
        let count = tagsStartIndexes.count
        guard count != 0, count == tagsEndIndexes.count else {
            assertionFailure("Unexpected tags count start: \(tagsStartIndexes.count) end: \(tagsEndIndexes.count)")
            throw CottonError.noVideoTags
        }
        
        let sourcURLParam = "src=\""
        for i in (0..<count) {
            let sIndex = tagsStartIndexes[i]
            let eIndex = tagsEndIndexes[i]
            let videoTagString = html[sIndex..<eIndex]
            
            guard let sourceURLParamRange = videoTagString.range(of: sourcURLParam) else {
                continue
            }
            
            let sourceSubstring = html[sourceURLParamRange.lowerBound..<eIndex]
        }
    }
}

extension HTMLVideoTagsContainer {
    enum CottonError: Error {
        case emptyHtml
        case noVideoTags
    }
}
