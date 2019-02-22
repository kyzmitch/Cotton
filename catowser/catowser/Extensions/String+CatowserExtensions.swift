//
//  String+CatowserExtensions.swift
//  catowser
//
//  Created by Andrei Ermoshin on 28/01/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

public extension String {
    public static func mainBundleName() -> String {
        return Bundle.main.bundleIdentifier ?? "com.ae.catowser"
    }

    public static func queueNameWith(suffix: String) -> String {
        return .mainBundleName() + ".\(suffix)"
    }
}
