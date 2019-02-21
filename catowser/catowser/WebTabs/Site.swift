//
//  Site.swift
//  catowser
//
//  Created by Andrei Ermoshin on 01/02/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

struct Site {
    /// Initial url
    let url: URL

    var domainString: String {
        // For http://www.opennet.ru/opennews/art.shtml?num=50072
        // it should be "www.opennet.ru"
        return url.host ?? "site"
    }

    init(url: URL) {
        self.url = url
    }

    init?(urlString: String) {
        guard let decodedUrl = URL(string: urlString) else {
            return nil
        }
        url = decodedUrl
    }
}

extension Site: Equatable {}
