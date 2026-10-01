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
        let environment = processInfo.environment
        if environment["XCTestConfigurationFilePath"] != nil {
            return true
        }
        if environment["XCTestBundlePath"] != nil {
            return true
        }
        if environment["XCTestSessionIdentifier"] != nil {
            return true
        }
        if processInfo.arguments.contains(where: { $0.contains("xctest") }) {
            return true
        }
        return NSClassFromString("XCTestCase") != nil
    }
}
