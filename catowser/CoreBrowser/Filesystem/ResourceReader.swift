//
//  ResourceReader.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 4/15/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation

public enum ResourceReader {
    public static func readSearchPlugin(with name: String, on bundle: Bundle) -> Data? {
        guard let bundleURL = bundle.resourceURL else {
            return nil
        }
        let pluginDirectory = bundleURL.appendingPathComponent(.searchPluginsFolder)
        let filePath = pluginDirectory.appendingPathComponent("\(name).xml").path
        let isExist = FileManager.default.fileExists(atPath: filePath)
        guard isExist else {
            return nil
        }
        let url = URL(fileURLWithPath: filePath)
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        return data
    }
}

extension String {
    static let searchPluginsFolder = "SearchPlugins"
}
