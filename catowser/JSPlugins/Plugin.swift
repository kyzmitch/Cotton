
//
//  Plugin.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 18/03/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import WebKit

public enum ScriptResourceName: String {
    case instagram = "ig"
    case jQueryAjax = "ajaxHandler"
}

public final class JSPluginFactory {
    static let shared = JSPluginFactory()

    private let scripts = NSCache<NSString, NSString>()

    private init() {
    }

    func script(for type: ScriptResourceName) -> String {
        if let existingJS = scripts.object(forKey: type.rawValue as NSString) {
            return existingJS as String
        } else {
            do {
                let script = try JSPluginFactory.loadScript(type)
                scripts.setObject(script as NSString, forKey: type.rawValue as NSString)
                return script
            } catch {

            }
        }
    }
}

fileprivate extension JSPluginFactory {
    static func loadScript(_ resourceName: ScriptResourceName) throws -> String {
        guard let filepath = Bundle.main.path(forResource: resourceName.rawValue, ofType: "js") else {
            print("\(resourceName.rawValue).js not found!")
            struct JSFileNotExist: Error {}
            throw JSFileNotExist()
        }

        return try String(contentsOfFile: filepath)
    }
}
