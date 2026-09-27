//
//  JSPluginFactory.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 18/03/2019.
//  Copyright © 2019 Cotton (former Catowser). All rights reserved.
//

import Foundation
import WebKit

@MainActor
final class JSPluginFactory {
    static let shared = JSPluginFactory()

    private let scripts = NSCache<NSString, WKUserScript>()

    func script(for plugin: any JavaScriptPlugin,
                with injectionTime: WKUserScriptInjectionTime,
                isMainFrameOnly: Bool) throws -> WKUserScript {
        let typeName = plugin.jsFileName
        if let existingJS = scripts.object(forKey: typeName as NSString) {
            return existingJS
        } else {
            let source = try Self.loadScriptSource(typeName)
            let wkScript = WKUserScript(source: source, injectionTime: injectionTime, forMainFrameOnly: isMainFrameOnly)
            scripts.setObject(wkScript, forKey: typeName as NSString)
            return wkScript
        }
    }
}

fileprivate extension JSPluginFactory {
    static func loadScriptSource(_ resourceName: String) throws -> String {
        guard let filepath = scriptFilePath(for: resourceName) else {
            throw CottonPluginError.jsFileNotFound(fileName: resourceName)
        }

        return try String(contentsOfFile: filepath)
    }

    static func scriptFilePath(for resourceName: String) -> String? {
        let bundles = [Bundle.module, Bundle(for: JSPluginFactory.self)]
        let subdirectories = ["Scripts/js", "js", nil as String?]
        for bundle in bundles {
            for subdirectory in subdirectories {
                if let path = bundle.path(
                    forResource: resourceName,
                    ofType: "js",
                    inDirectory: subdirectory
                ) {
                    return path
                }
            }
        }
        return nil
    }
}
