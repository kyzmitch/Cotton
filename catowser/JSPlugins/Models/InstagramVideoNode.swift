//
//  InstagramVideoNode.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 3/26/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

/// Describes INSTAGRAM video post json object
public struct InstagramVideoNode: Decodable {
    /// The URL which points to remote video file
    public let videoUrl: URL
    /// The URL which points to remote image file for the video preview
    public let thumbnailUrl: URL

    /// The image created from Base64 data
    public let mediaPreview: UIImage?
    /// The resolution of the video clip
    public let dimensions: CGSize?
    /// The name of video
    public let name: String
    /// Video file name
    public var fileName: String {
        return "\(name).mp4"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeName: String = try container.decode(String.self, forKey: .typeName)
        let isVideo: Bool = try container.decode(Bool.self, forKey: .isVideo)
        guard isVideo || typeName == "GraphVideo" else {
            throw DecodingError.notVideo
        }

        // Using `try?` to ignore exceptions for these optional keys.
        // And sending an exception if both possible keys are not present.

        if let closedDisplayURL = try? container.decodeIfPresent(URL.self, forKey: .displayUrl), let displayURL = closedDisplayURL {
            thumbnailUrl = displayURL
        } else if let closedThumbnailSrc = try? container.decodeIfPresent(URL.self, forKey: .thumbnailSrc), let thumbnailSrc = closedThumbnailSrc {
            thumbnailUrl = thumbnailSrc
        } else {
            throw DecodingError.missingPreviewURL
        }

        // Using `try` to automatically send exception, because video is mandatory key

        videoUrl = try container.decode(URL.self, forKey: .videoUrl)

        if  let closedBase64String = try? container.decodeIfPresent(String.self, forKey: .mediaPreview),
            let base64String = closedBase64String,
            let mediaPreviewData = Data(base64Encoded: base64String) {
            // UIImage can't be created with base64 value for some reason
            mediaPreview = UIImage(data: mediaPreviewData)
        } else {
            mediaPreview = nil
        }
        dimensions = nil

        do {
            let mediaCaption = try container.decode(IgEdgeMediaCaption.self, forKey: .mediaCaption)
            if let edge = mediaCaption.edges.first {
                name = edge.node.text
            } else {
                name = UUID().uuidString
            }
        } catch {
            print("Media caption isn't set for post")
            name = UUID().uuidString
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
    }
    
    enum DecodingError: Error {
        case notVideo
        case missingPreviewURL
        case wrongBase64String
        case wrongDataForImage
    }
}

fileprivate struct IgEdgeMediaCaption: Decodable {
    let edges: [IgMediaCaptionEdge]

    fileprivate struct IgMediaCaptionNodeText: Decodable {
        let text: String
    }

    fileprivate struct IgMediaCaptionEdge: Decodable {
        let node: IgMediaCaptionNodeText
    }
}

extension InstagramVideoNode: Equatable {}
