//
//  InstagramVideoArray.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 3/27/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

public struct InstagramVideoArray: Decodable {
    public let nodes: [InstagramVideoNode]
    
    public init(from decoder: Decoder) throws {
        var nodes = [InstagramVideoNode]()
        var container = try decoder.unkeyedContainer()
        while !container.isAtEnd {
            do {
                let node = try container.decode(Dictionary<String, InstagramVideoNode>.self)
                guard node.first?.key == "node" else {
                    throw CottonError.notExpectedKey
                }
                if let videoNode = node.first?.value {
                    nodes.append(videoNode)
                }
            } catch {
                // https://stackoverflow.com/a/46713058
                _ = try? container.decode(CottonDummyCodable.self)
            }
        }
        self.nodes = nodes
    }
    
    enum CottonError: Error {
        case notExpectedKey
    }
}
