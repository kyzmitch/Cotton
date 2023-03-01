//
//  EnvironmentValues+Extension.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/18/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI

/**
 https://sarunw.com/posts/how-to-define-custom-environment-values-in-swiftui/
 https://useyourloaf.com/blog/swiftui-custom-environment-values/
 */

private struct BrowserContentCoordinatorsKey: EnvironmentKey {
    static let defaultValue: BrowserContentCoordinators? = nil
}

extension EnvironmentValues {
    var browserContentCoordinators: BrowserContentCoordinators? {
        get { self[BrowserContentCoordinatorsKey.self] }
        set { self[BrowserContentCoordinatorsKey.self] = newValue }
    }
}
