//
//  InstagramVideoNode.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 3/26/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import UIKit

/// Describes INSTAGRAM video post json object
public struct InstagramVideoNode: Decodable, VideoFileNameble {
    /// The URL which points to remote video file
    public let videoUrl: URL
    /// The URL which points to remote image file for the video preview
    public let thumbnailUrl: URL

    /// The image created from Base64 data
    public let mediaPreview: UIImage?
    /// The resolution of the video clip
    public let dimensions: CGSize?
    /// The name of video
    public let fileDescription: String
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeName: String = try container.decode(String.self, forKey: .typeName)
        let isVideo: Bool = try container.decode(Bool.self, forKey: .isVideo)
        guard isVideo || typeName == "GraphVideo" else {
            throw DecodingError.notVideo
        }

        // Using `try?` to ignore exceptions for these optional keys.
        // And sending an exception if both possible keys are not present.

        if let displayURL = try? container.decodeIfPresent(URL.self, forKey: .displayUrl) {
            thumbnailUrl = displayURL
        } else if let thumbnailSrc = try? container.decodeIfPresent(URL.self, forKey: .thumbnailSrc) {
            thumbnailUrl = thumbnailSrc
        } else {
            throw DecodingError.missingPreviewURL
        }

        // Using `try` to automatically send exception, because video is mandatory key

        videoUrl = try container.decode(URL.self, forKey: .videoUrl)

        if  let base64String = try? container.decodeIfPresent(String.self, forKey: .mediaPreview),
            let mediaPreviewData = Data(base64Encoded: base64String) {
            // UIImage can't be created with base64 value for some reason
            mediaPreview = UIImage(data: mediaPreviewData)
        } else {
            mediaPreview = nil
        }
        dimensions = nil

        let possiblePageTitle = try? container.decode(String.self, forKey: .pageTitle)
        let possibleMediaCaption = try? container.decode(IgEdgeMediaCaption.self, forKey: .mediaCaption)
        
        if let pageTitle = possiblePageTitle, !pageTitle.contains("undefined") {
            fileDescription = pageTitle
        } else if let mediaCaption = possibleMediaCaption, let edge = mediaCaption.edges.first {
            fileDescription = edge.node.text
        } else {
            fileDescription = "instagram_fileWithoutName_\(thumbnailUrl.path))"
        }
    }
}

extension InstagramVideoNode {
    enum CodingKeys: String, CodingKey {
        case mediaPreview = "media_preview"
        case displayUrl = "display_url"
        case thumbnailSrc = "thumbnail_src"
        case isVideo = "is_video"
        case typeName = "__typename"
        case videoUrl = "video_url"
        case videoDuration = "video_duration"
        case mediaCaption = "edge_media_to_caption"
        case pageTitle = "pageTitle"
    }
    
    enum DecodingError: Error {
        case notVideo
        case missingPreviewURL
        case wrongBase64String
        case wrongDataForImage
    }
}

private struct IgEdgeMediaCaption: Decodable {
    let edges: [IgMediaCaptionEdge]

    fileprivate struct IgMediaCaptionNodeText: Decodable {
        let text: String
    }

    fileprivate struct IgMediaCaptionEdge: Decodable {
        let node: IgMediaCaptionNodeText
    }
}

extension InstagramVideoNode: Equatable {}
