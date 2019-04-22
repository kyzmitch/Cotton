//
//  T4VideoDictionary.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 22/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

public struct T4VideoDictionary: Decodable {
    public let videos: [T4Video]

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: T4Video.Resolution.self)
        var array = [T4Video]()
        if let video240p = try? container.decode(T4Video.self, forKey: .p240) {
            array.append(video240p)
        }
        if let video360p = try? container.decode(T4Video.self, forKey: .p360) {
            array.append(video360p)
        }
        if let video480p = try? container.decode(T4Video.self, forKey: .p480) {
            array.append(video480p)
        }
        if let video720p = try? container.decode(T4Video.self, forKey: .p720) {
            array.append(video720p)
        }
        if let video1080p = try? container.decode(T4Video.self, forKey: .p1080) {
            array.append(video1080p)
        }
        guard array.count != 0 else {
            throw CottonError.noVideos
        }
        videos = array
    }
}

extension T4VideoDictionary {
    enum CottonError: Error {
        case noVideos
    }
}
