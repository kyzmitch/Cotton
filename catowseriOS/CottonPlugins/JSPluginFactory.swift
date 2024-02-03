//
//  JSPluginFactory.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 18/03/2019.
//  Copyright © 2019 Cotton (former Catowser). All rights reserved.
//

import Foundation
import WebKit

final class JSPluginFactory {
    static let shared = JSPluginFactory()

    private let scripts = NSCache<NSString, WKUserScript>()

    private init() {}

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
        guard let filepath = Bundle.init(for: self).path(forResource: resourceName, ofType: "js") else {
            print("\(resourceName).js not found!")
            struct JSFileNotExist: Error {}
            throw JSFileNotExist()
        }

        return try String(contentsOfFile: filepath)
    }
}
