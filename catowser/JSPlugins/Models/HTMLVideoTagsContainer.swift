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
    
    init(htmlMessage: HTMLContentMessage) throws {
        let videoElements: Elements
        do {
            videoElements = try htmlMessage.html.select("video")
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
        let docTitle = htmlMessage.html.documentTitle
        let mainPosterURL = htmlMessage.mainPosterURL
        
        var result: [HTMLVideoTag] = []
        for (i, videoElement) in videoElements.enumerated() {
            let htmlVideoTag = HTMLVideoTag(videoElement, i, docTitle, mainPosterURL)
            guard let tag = htmlVideoTag else { continue }
            result.append(tag)
        }
        
        guard result.count > 0 else {
            throw CottonError.noVideoTags
        }
        videoTags = result
    }
}

enum CottonError: Error {
    case parseError
    case emptyHtml
    case noVideoTags
    case parseHost
}

extension Document {
    var documentTitle: String {
        let docTitle: String
        if let title = try? title() {
            docTitle = title
        } else if let docURL = URL(string: location()),
            let hostname = docURL.host {
            docTitle = hostname
        } else {
            docTitle = UUID().uuidString
        }
        return docTitle
    }
}
