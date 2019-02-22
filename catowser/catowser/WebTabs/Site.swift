//
//  Site.swift
//  catowser
//
//  Created by Andrei Ermoshin on 01/02/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

public struct Site {
    /// Initial url
    public let url: URL

    public var domainString: String {
        // For http://www.opennet.ru/opennews/art.shtml?num=50072
        // it should be "www.opennet.ru"
        return url.host ?? "site"
    }

    public init(url: URL) {
        self.url = url
    }

    public init?(urlString: String) {
        guard let decodedUrl = URL(string: urlString) else {
            return nil
        }
        url = decodedUrl
    }
}

extension Site: Equatable {}
