//
//  InstagramVideoArray.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 3/27/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

@available(*, deprecated, message: "Parsing logic moved to JavaScript extension")
public struct InstagramVideoArray: Decodable {
    public let nodes: [InstagramVideoNode]
    
    public init(from decoder: Decoder) throws {
        var nodes = [InstagramVideoNode]()
        var container = try decoder.unkeyedContainer()
        while !container.isAtEnd {
            do {
                let node = try container.decode(Dictionary<String, InstagramVideoNode>.self)
                guard node.first?.key == "node" else {
                    throw CottonPluginError.notExpectedKey
                }
                if let videoNode = node.first?.value {
                    nodes.append(videoNode)
                }
            } catch {
                // https://stackoverflow.com/a/46713058
                // this is to do something like `continue`
                // in the loop if some condition is not met
                // in this case it is when exception is raised
                // because JSON sometimes couldn't contain all
                // needed properties to construct an object
                _ = try? container.decode(CottonDummyDecodable.self)
            }
        }
        self.nodes = nodes
    }
}
