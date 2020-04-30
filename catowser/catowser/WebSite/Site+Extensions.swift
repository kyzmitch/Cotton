//
//  Site+Extensions.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/30/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
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
