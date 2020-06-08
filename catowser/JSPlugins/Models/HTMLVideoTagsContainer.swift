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
        let docTitle = Self.parseTitle(htmlMessage.html)
        let mainPoster: URL? = Self.parseMainPoster(from: htmlMessage)
        
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
                guard let sourceURL = try? sources?.first()?.attr("src") else {
                    print("Found video tag source subtag but without URL")
                    continue
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

            let tagName = "\(docTitle)-\(i)"
            guard let srcURL = URL(string: videoUrl) else {
                continue
            }
            let posterURL = Self.getFinalPosterURL(thumbnailURLString, mainPoster)
            let videoTag = HTMLVideoTag(srcURL: srcURL, posterURL: posterURL, name: tagName)
            guard let tag = videoTag else {
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
    
    private static func parseMainPoster(from htmlMessage: HTMLContentMessage) -> URL? {
        if htmlMessage.hostname.isSimilar(with: "youtube.com") {
            let divs: Elements
            do {
                divs = try htmlMessage.html.select("div[class*=ytp-cued-thumbnail-overlay-image]")
                // or use `getElementsByClass` but it's not optimal and requires
                // to fetch all divs which we don't need
            } catch {
                print("Failed to find poster for youtube: \(error)")
                return nil
            }
            let thumbnailCssStyle: String?
            do {
                thumbnailCssStyle = try divs.first()?.attr("style")
            } catch {
                print("Failed to extract css style from youtube thumbnail \(error)")
                return nil
            }
            guard let cssString = thumbnailCssStyle else {
                print("Empty string for youtube thumbnail css")
                return nil
            }
            return CSSBackgroundImage(cssString: cssString)?.firstURL
        }
        return nil
    }
    
    private static func getFinalPosterURL(_ specificThumbnail: String?, _ mainPoster: URL?) -> URL? {
        if let bestThumbnail = specificThumbnail,
            let thumbnailURL = URL(string: bestThumbnail) {
            return thumbnailURL
        }
        return mainPoster
    }
    
    private static func parseTitle(_ doc: Document) -> String {
        let docTitle: String
        if let title = try? doc.title() {
            docTitle = title
        } else {
            docTitle = UUID().uuidString
        }
        return docTitle
    }
}

enum CottonError: Error {
    case parseError
    case emptyHtml
    case noVideoTags
    case parseHost
}
