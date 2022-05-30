//
//  JavaScriptPlugin.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 5/30/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import WebKit

// Need to use struct or class instead of enum, because it breaks Solid Open/Closed principle
// And it is not convinient to make association with delegate protocol for plugin handler
// because every handler will have own delegate protocol

public enum PluginHandlerDelegateType {
    case base(BasePluginContentDelegate)
    case instagram(InstagramContentDelegate)
}

public protocol JavaScriptPlugin {
    var jsFileName: String { get }
    var messageHandlerName: String { get }
    var isMainFrameOnly: Bool { get }
    var handler: WKScriptMessageHandler { get }
    var hostKeyword: String { get }
    func scriptString(_ enable: Bool) -> String?
    init?(delegate: PluginHandlerDelegateType)
    init?(anyProtocol: Any)
}
