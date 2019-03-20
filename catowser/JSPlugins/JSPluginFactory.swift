
//
//  JSPluginFactory.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 18/03/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import WebKit

/// JS Plugin handler where `rawValue` represent js script name
public enum JSPluginName: String {
    case instagram = "ig"
    case jQueryAjax = "jquery_ajax"

    /// JS var name
    var messageHandlerName: String {
        switch self {
        case .instagram:
            return "igHandler"
        case .jQueryAjax:
            return "jQueryHandler"
        }
    }

    var mainFrameOnly: Bool {
        switch self {
        case .instagram:
            return false
        case .jQueryAjax:
            return true
        }
    }

}

// extension JSPluginName: Hashable {}

final class JSPluginFactory {
    static let shared = JSPluginFactory()

    private let scripts = NSCache<NSString, WKUserScript>()

    private init() {}

    func script(for type: JSPluginName) throws -> WKUserScript {
        let typeName = type.rawValue
        if let existingJS = scripts.object(forKey: typeName as NSString) {
            return existingJS
        } else {
            let source = try JSPluginFactory.loadScriptSource(typeName)
            let wkScript = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: type.mainFrameOnly)
            scripts.setObject(wkScript, forKey: typeName as NSString)
            return wkScript
        }
    }
}

fileprivate extension JSPluginFactory {
    static func loadScriptSource(_ resourceName: JSPluginName.RawValue) throws -> String {
        guard let filepath = Bundle.init(for: self).path(forResource: resourceName, ofType: "js") else {
            print("\(resourceName).js not found!")
            struct JSFileNotExist: Error {}
            throw JSFileNotExist()
        }

        return try String(contentsOfFile: filepath)
    }
}
