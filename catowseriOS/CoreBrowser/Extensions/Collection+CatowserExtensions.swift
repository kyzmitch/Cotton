//
//  Collection+CatowserExtensions.swift
//  catowser
//
//  Created by Andrei Ermoshin on 24/01/2019.
//  Copyright © 2019 Cotton (former Catowser). All rights reserved.
//

import Foundation

public extension Collection {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
