
//
//  JSPluginFactory.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 18/03/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import WebKit

// Need to use struct or class instead of enum, because it breaks Solid Open/Closed principle
// And it is not convinient to make association with delegate protocol for plugin handler
// because every handler will have own delegate protocol

public enum PluginHandlerDelegate {
    case instagram(InstagramContentDelegate?)
    case jQueryAjax
}

public protocol CottonJSPlugin {
    var jsFileName: String { get }
    var messageHandlerName: String { get }
    var isMainFrameOnly: Bool { get }
    var delegate: PluginHandlerDelegate { get }
}

public struct InstagramContentPlugin: CottonJSPlugin {
    public var delegate: PluginHandlerDelegate = .instagram(nil)

    public let jsFileName: String = "ig"

    public let messageHandlerName: String = "igHandler"

    public let isMainFrameOnly: Bool = false
}

public struct JQueryAjaxLinksPlugin: CottonJSPlugin {
    public var delegate: PluginHandlerDelegate = .jQueryAjax

    public let jsFileName: String = "jquery_ajax"

    public let messageHandlerName: String = "jQueryHandler"

    public let isMainFrameOnly: Bool = true
}

final class JSPluginFactory {
    static let shared = JSPluginFactory()

    private let scripts = NSCache<NSString, WKUserScript>()

    private init() {}

    func script(for type: CottonJSPlugin) throws -> WKUserScript {
        let typeName = type.jsFileName
        if let existingJS = scripts.object(forKey: typeName as NSString) {
            return existingJS
        } else {
            let source = try JSPluginFactory.loadScriptSource(typeName)
            let wkScript = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: type.isMainFrameOnly)
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
