//
//  Host+Extension.swift
//  catowser
//
//  Created by Andrei Ermoshin on 8/28/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CottonCoreBaseKit

public extension CottonCoreBaseKit.Host {
    func isSimilar(with url: URL) -> Bool {
        guard let rawHostString = url.host else { return false }
        return isSimilar(name: rawHostString)
    }
}
