//
//  LocalSettings.swift
//  FeaturesFlagsKit
//
//  Created by Andrei Ermoshin on 2/22/20.
//  Copyright © 2020 Cotton (former Catowser). All rights reserved.
//

import Foundation

final class LocalSettings {
    private static let shared: LocalSettings = .init()

    private let userDefaults: UserDefaults

    private init() {
        userDefaults = .init()
    }

    static func getGlobalStringSetting(for key: String) -> String? {
        return shared.userDefaults.string(forKey: key)
    }

    static func getGlobalIntSetting(for key: String) -> Int? {
        guard shared.userDefaults.object(forKey: key) != nil else {
            return nil
        }
        return shared.userDefaults.integer(forKey: key)
    }

    static func getGlobalBoolSetting(for key: String) -> Bool? {
        guard shared.userDefaults.object(forKey: key) != nil else {
            return nil
        }
        return shared.userDefaults.bool(forKey: key)
    }

    static func setGlobalBoolSetting(for key: String, value: Bool) {
        shared.userDefaults.set(value, forKey: key)
    }

    static func setGlobalIntSetting(for key: String, value: Int) {
        shared.userDefaults.set(value, forKey: key)
    }
}
