//
//  T4Video.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 22/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

public struct T4Video: Decodable {
    public let variants: [Resolution: URL]

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Resolution.self)
        var set = [Resolution: URL]()
        var atleastOne = false
        if let video240p = try? container.decode(T4VideoContainer.self, forKey: .p240) {
            set[.p240] = video240p.token
            atleastOne = true
        }
        if let video360p = try? container.decode(T4VideoContainer.self, forKey: .p360) {
            set[.p360] = video360p.token
            atleastOne = true
        }
        if let video480p = try? container.decode(T4VideoContainer.self, forKey: .p480) {
            set[.p480] = video480p.token
            atleastOne = true
        }
        if let video720p = try? container.decode(T4VideoContainer.self, forKey: .p720) {
            set[.p720] = video720p.token
            atleastOne = true
        }
        if let video1080p = try? container.decode(T4VideoContainer.self, forKey: .p1080) {
            set[.p1080] = video1080p.token
            atleastOne = true
        }
        guard atleastOne else {
            throw CottonError.noVideos
        }
        
        variants = set
    }
}

extension T4Video {
    public enum Resolution: String {
        case p240 = "240"
        case p360 = "360"
        case p480 = "480"
        case p720 = "720"
        case p1080 = "1080"
    }
    
    enum CottonError: Error {
        case noVideos
    }
}

extension T4Video: Equatable {}

extension T4Video.Resolution: CodingKey {}

fileprivate struct T4VideoContainer: Decodable {
    let token: URL
}
