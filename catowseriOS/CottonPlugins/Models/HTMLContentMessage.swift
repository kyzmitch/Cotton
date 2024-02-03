//
//  HTMLContentMessage.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 6/8/20.
//  Copyright © 2020 Cotton (former Catowser). All rights reserved.
//

import Foundation
import CottonBase
import SwiftSoup

struct HTMLContentMessage: Decodable {
    let hostname: CottonBase.Host
    let html: Document
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let hostnameString = try container.decode(String.self, forKey: .hostname)
        guard let kitHost = try? CottonBase.Host(input: hostnameString) else {
            throw CottonPluginError.parseHost
        }
        hostname = kitHost
        let htmlString = try container.decode(String.self, forKey: .htmlString)
        html = try SwiftSoup.parse(htmlString)
    }
    
    var mainPosterURL: URL? {
        if hostname.isSimilar(name: "youtube.com") {
            let divs: Elements
            do {
                divs = try html.select("div[class*=ytp-cued-thumbnail-overlay-image]")
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
    
    private enum CodingKeys: String, CodingKey {
        case hostname
        case htmlString
    }
}
