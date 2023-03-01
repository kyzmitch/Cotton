//
//  ResourceReader.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 4/15/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation

public enum KnownSearchPluginName: String {
    case google
    case duckduckgo
}

public enum ResourceReader {
    public static func readXmlSearchPlugin(with name: KnownSearchPluginName,
                                           on bundle: Bundle) -> Data? {
        guard let fileURL = bundle.url(forResource: name.rawValue, withExtension: "xml") else {
            return nil
        }
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        return data
    }
}

extension String {
    static let searchPluginsFolder = "SearchPlugins"
}
