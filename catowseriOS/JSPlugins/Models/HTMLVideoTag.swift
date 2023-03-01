//
//  HTMLVideoTag.swift
//  JSPlugins
//
//  Created by Andrey Ermoshin on 17/05/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import SwiftSoup

public struct HTMLVideoTag {
    public let src: URL
    public let poster: URL?
    public let fileDescription: String
    
    public init(srcURL: URL, posterURL: URL?, name: String) {
        src = srcURL
        poster = posterURL
        self.fileDescription = name
    }
    
    init?(_ videoElement: Element,
          _ elementIndex: Int,
          _ docTitle: String,
          _ mainPosterURL: URL?) {
        // The URL of the video to embed. This is optional;
        // you may instead use the <source> element within the video block
        // to specify the video to embed.
        let videoUrl: String
        if let srcURLString: String = try? videoElement.attr("src") {
            videoUrl = srcURLString
        } else {
            let sources = try? videoElement.select("source")
            guard let sourceURL = try? sources?.first()?.attr("src") else {
                print("Found video tag source subtag but without URL")
                return nil
            }
            videoUrl = sourceURL
        }
        // The poster URL is optional too
        let thumbnailURLString: String?
        if let posterString = try? videoElement.attr("poster") {
            thumbnailURLString = posterString.isEmpty ? nil : posterString
        } else {
            thumbnailURLString = nil
        }

        let tagName = "\(docTitle)-\(elementIndex + 1)"
        guard let srcURL = URL(string: videoUrl) else {
            return nil
        }
        
        self.src = srcURL
        self.poster = Self.finalPosterURL(thumbnailURLString, mainPosterURL)
        self.fileDescription = tagName
    }
    
    private static func finalPosterURL(_ specificThumbnail: String?, _ mainPosterURL: URL?) -> URL? {
        if let bestThumbnail = specificThumbnail,
            let thumbnailURL = URL(string: bestThumbnail) {
            return thumbnailURL
        }
        return mainPosterURL
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

        fileDescription = "htmlVideoTag_\(src.path)"
    }
}

extension HTMLVideoTag {
    enum CodingKeys: String, CodingKey {
        case src
        case poster
    }
}

extension HTMLVideoTag: Equatable {}
