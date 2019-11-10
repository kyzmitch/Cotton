//
//  String+JSExtensions.swift
//  JSPlugins
//
//  Created by Andrey Ermoshin on 16/05/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

extension String {
    func indices(of searchTerm: String) -> [Int] {
        var indices: [String.IndexDistance] = []
        var pos: String.Index = startIndex
        while let range = range(of: searchTerm, range: pos ..< endIndex) {
            let termStartIndex: String.IndexDistance = distance(from: startIndex, to: range.lowerBound)
            indices.append(termStartIndex)
            pos = index(after: range.lowerBound)
        }
        return indices
    }
}
