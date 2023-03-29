//
//  String+Extension.swift
//  catowser
//
//  Created by Andrei Ermoshin on 3/30/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import Foundation

// See: https://github.com/apple/sample-cloudkit-queries/
// blob/592b76cce844f7474499831e6bd2c76ef485fed1/Queries/ContentView.swift

/// Allows to use String in SwiftUI List view
extension String: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}
