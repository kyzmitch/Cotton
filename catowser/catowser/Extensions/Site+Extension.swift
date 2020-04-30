//
//  Site+Extension.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/11/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import CoreBrowser

extension Site {
    var faviconURL: URL? {
        if FeatureManager.boolValue(of: .dnsOverHTTPSAvailable) {
            return URL(faviconIPInfo: url)
        } else {
            return URL(faviconHost: url.host)
        }
    }
}
