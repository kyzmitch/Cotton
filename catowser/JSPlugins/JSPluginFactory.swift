
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

public enum PluginHandlerDelegateType {
    case instagram(InstagramContentDelegate)
    case t4
}

public protocol CottonJSPlugin {
    var jsFileName: String { get }
    var messageHandlerName: String { get }
    var isMainFrameOnly: Bool { get }
    var delegate: PluginHandlerDelegateType { get }
    var handler: WKScriptMessageHandler { get }
    init?(delegate: PluginHandlerDelegateType)
    init?(anyProtocol: Any)
}

final class JSPluginFactory {
    static let shared = JSPluginFactory()

    private let scripts = NSCache<NSString, WKUserScript>()

    private init() {}

    func script(for plugin: CottonJSPlugin) throws -> WKUserScript {
        let typeName = plugin.jsFileName
        if let existingJS = scripts.object(forKey: typeName as NSString) {
            return existingJS
        } else {
            let source = try JSPluginFactory.loadScriptSource(typeName)
            let wkScript = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: plugin.isMainFrameOnly)
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
