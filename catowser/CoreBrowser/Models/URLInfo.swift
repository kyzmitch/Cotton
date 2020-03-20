//
//  URLInfo.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 3/20/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation

public struct URLInfo {
    public let url: URL
    public var ipAddress: String?
    
    public init(_ url: URL) {
        self.url = url
        ipAddress = nil
    }
}
