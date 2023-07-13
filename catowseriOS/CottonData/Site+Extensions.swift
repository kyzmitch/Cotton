//
//  Site+Extensions.swift
//  CoreCatowser
//
//  Created by Andrei Ermoshin on 10/3/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import CottonBase

extension Site {
    static func create(urlInfo: URLInfo, settings: Settings) -> Site {
        let site = Site(urlInfo: urlInfo,
                        settings: settings,
                        faviconData: nil,
                        searchSuggestion: nil,
                        userSpecifiedTitle: nil)
        return site
    }
}
