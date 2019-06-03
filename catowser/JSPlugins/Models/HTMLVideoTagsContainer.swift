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
        
        let videoElements: Elements
        let docTitle: String
        do {
            let doc: Document = try SwiftSoup.parse(html)
            videoElements = try doc.select("video")

            if let title = try? doc.title() {
                docTitle = title
            } else {
                docTitle = UUID().uuidString
            }
        } catch Exception.Error( _, let message) {
            print("Failed parse html video tags: \(message)")
            throw CottonError.parseError
        } catch {
            print("Failed to parse html video tags")
            throw CottonError.parseError
        }
        
        guard videoElements.size() > 0 else {
            throw CottonError.noVideoTags
        }
        var result: [HTMLVideoTag] = []
        for (i, videoElement) in videoElements.enumerated() {
            // The URL of the video to embed. This is optional;
            // you may instead use the <source> element within the video block
            // to specify the video to embed.
            let videoUrl: String
            if let srcURLString: String = try? videoElement.attr("src") {
                videoUrl = srcURLString
            } else {
                let sources = try? videoElement.select("source")
                guard let srcURL = try? sources?.first()?.attr("src"), let sourceURL = srcURL else {
                    print("Found video tag source subtag but without URL")
                    continue
                }
                videoUrl = sourceURL
            }
            // The poster URL is optional too
            let thumbnailURL: String? = try? videoElement.attr("poster")

            let tagName = "\(docTitle)-\(i)"
            guard let tag = HTMLVideoTag(srcString: videoUrl, posterString: thumbnailURL, name: tagName) else {
                print("Failed create video tag object with URLs")
                continue
            }
            result.append(tag)
        }
        
        guard result.count > 0 else {
            throw CottonError.noVideoTags
        }
        videoTags = result
    }
}

extension HTMLVideoTagsContainer {
    enum CottonError: Error {
        case parseError
        case emptyHtml
        case noVideoTags
    }
}
