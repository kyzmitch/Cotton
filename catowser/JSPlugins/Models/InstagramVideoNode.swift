//
//  InstagramVideoNode.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 3/26/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

public struct InstagramVideoNode: Decodable {
    let mediaPreview: UIImage?
    let videUrl: URL
    let thumbnailUrl: URL
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let isVideo: Bool = try container.decode(Bool.self, forKey: .isVideo)
        guard isVideo else {
            throw DecodingError.notVideo
        }
        if let base64String = try container.decodeIfPresent(String.self, forKey: .mediaPreview), let mediaPreviewData = Data(base64Encoded: base64String) {
            mediaPreview = UIImage(data: mediaPreviewData)
        } else {
            // TODO: need to identify why UIImage can't be created with current base64 value
            mediaPreview = nil
        }
        
        videUrl = try container.decode(URL.self, forKey: .videUrl)
        thumbnailUrl = try container.decode(URL.self, forKey: .thumbnailUrl)
    }
}

extension InstagramVideoNode {
    enum CodingKeys: String, CodingKey {
        case mediaPreview = "media_preview"
        case isVideo = "is_video"
        case videUrl = "video_url"
        case thumbnailUrl = "thumbnail_src"
        case videoDuration = "video_duration"
    }
    
    enum DecodingError: Error {
        case notVideo
        case wrongBase64String
        case wrongDataForImage
    }
}

/*
 "node": {
    "__typename": "GraphVideo",
    "id": "1925189943719911217",
    "shortcode": "Bq3pg3AlF8x",
    "dimensions": {
        "height": 750,
        "width": 750
    },
    "gating_info": null,
    "media_preview": "base64 string",
    "display_url": "jpg url string",
    "display_resources":
 [
    {
        "src": "jpg url string",
        "config_width": 640,
        "config_height": 640
    },
    {
        "src": "jpg url string",
        "config_width": 750,
        "config_height": 750
    },
    {
        "src": "jpg url string",
        "config_width": 1080,
        "config_height": 1080
    }
 ],
    "dash_info": {
        "is_dash_eligible": false,
        "video_dash_manifest": null,
        "number_of_qualities": 0
    },
    "video_url": "mp4 url string",
    "video_view_count": 14,
    "is_video": true,
    "should_log_client_event": false,
    "tracking_token": "random symbols string",
    "edge_media_to_tagged_user": {
        "edges": []
    }
 }
 */
