//
//  AutoMockable.swift
//  AutoMockable
//
//  Created by Andrei Ermoshin on 10/27/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation

public protocol AutoMockable { }
public protocol AutoHashable {}

public extension ProcessInfo {
    static var unitTesting: Bool {
        processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}
