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
        // TODO: parse url to extract only domain name
        // http://www.opennet.ru/opennews/art.shtml?num=50072
        return "www.opennet.ru"
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

extension Site: Equatable {
    
}
