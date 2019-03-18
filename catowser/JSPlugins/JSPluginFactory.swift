
//
//  JSPluginFactory.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 18/03/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import WebKit

public enum JSPluginName: String {
    case instagram = "ig"
    case jQueryAjax = "jquery_ajax"
    
    var messageHandlerName: String {
        switch self {
        case .instagram:
            return "igHandler"
        case .jQueryAjax:
            return "jQueryHandler"
        }
    }
    
    var scriptHandler: WKScriptMessageHandler {
        switch self {
        case .instagram:
            let ig = InstagramHandler()
            return ig
        case .jQueryAjax:
            let jquery = JQueryHandler()
            return jquery
        }
    }
}

final class JSPluginFactory {
    static let shared = JSPluginFactory()

    private let scripts = NSCache<NSString, WKUserScript>()

    private init() {}

    func script(for type: JSPluginName) throws -> WKUserScript {
        if let existingJS = scripts.object(forKey: type.rawValue as NSString) {
            return existingJS
        } else {
            let source = try JSPluginFactory.loadScriptSource(type)
            let wkScript = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            scripts.setObject(wkScript, forKey: type.rawValue as NSString)
            return wkScript
        }
    }
}

fileprivate extension JSPluginFactory {
    static func loadScriptSource(_ resourceName: JSPluginName) throws -> String {
        guard let filepath = Bundle.init(for: self).path(forResource: resourceName.rawValue, ofType: "js") else {
            print("\(resourceName.rawValue).js not found!")
            struct JSFileNotExist: Error {}
            throw JSFileNotExist()
        }

        return try String(contentsOfFile: filepath)
    }
}
