//
//  HTMLVideoTagsContainer.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 04/05/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import SwiftSoup

public struct HTMLVideoTagsContainer {
    public let videoURLs: [URL]
    init(html: String) throws {
        guard html.count > 0 else {
            throw CottonError.emptyHtml
        }
        
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let videoTags: Elements = try doc.select("video")
            
            for videoTag in videoTags {
                let videoUrl: String = try videoTag.attr("src")
                let thumanailURL: String = try videoTag.attr("poster")
            }
        } catch Exception.Error(let type, let message) {
            print("Failed parse html: \(message)")
            throw CottonError.parseError
        } catch {
            print("Failed to parse html")
            throw CottonError.parseError
        }
    }
}

extension HTMLVideoTagsContainer {
    enum CottonError: Error {
        case parseError
        case emptyHtml
        case noVideoTags
    }
}
