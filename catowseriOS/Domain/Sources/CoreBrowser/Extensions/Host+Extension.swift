//
//  Host+Extension.swift
//  catowser
//
//  Created by Andrei Ermoshin on 8/28/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import CottonBase

public extension CottonBase.Host {
    func isSimilar(with url: URL) -> Bool {
        guard let rawHostString = url.host else { return false }
        return isSimilar(name: rawHostString)
    }
}
