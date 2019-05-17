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
    public let videoTags: [HTMLVideoTag]
    
    init(html: String) throws {
        guard html.count > 0 else {
            throw CottonError.emptyHtml
        }
        
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let videoElements: Elements = try doc.select("video")
        } catch Exception.Error(let type, let message) {
            print("Failed parse html video tags: \(message)")
            throw CottonError.parseError
        } catch {
            print("Failed to parse html video tags")
            throw CottonError.parseError
        }
        
        for videoElement in videoElements {
            guard let videoUrl: String = try? videoElement.attr("src") else {
                continue
            }
            guard let thumanailURL: String = try? videoElement.attr("poster") else {
                continue
            }
            
            let tag = HTMLVideoTag(
            
        }
    }
}

extension HTMLVideoTagsContainer {
    enum CottonError: Error {
        case parseError
        case videoSrcParseError
        case emptyHtml
        case noVideoTags
    }
}
