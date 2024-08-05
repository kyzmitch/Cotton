//
//  JavaScriptPlugin.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 5/30/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation
import WebKit
import CottonBase

// Need to use struct or class instead of enum, because it breaks Solid Open/Closed principle
// And it is not convinient to make association with delegate protocol for plugin handler
// because every handler will have own delegate protocol

public enum PluginHandlerDelegateType {
    case base(BasePluginContentDelegate)
    case instagram(InstagramContentDelegate)
}

/**
 Describes the JavaScript plugin model.
 An Element from visitor design pattern.
 */
public protocol JavaScriptPlugin: Equatable {
    var jsFileName: String { get }
    var messageHandlerName: String { get }
    var isMainFrameOnly: Bool { get }
    var hostKeyword: String? { get }
    /**
     Constructs a JavaScript string with specific variable
     for controlling specific plugin in web view

     - Parameters:
     - enable determines if specific plugin should be turned on/off
     */
    func scriptString(_ enable: Bool) -> String?

    /**
     Handles the visitor depending on context.

     - Parameters:
     - host represents the hostname from web view (can be used to determine if specific plugin is applicable or not)
     - canInject shows if this specific plugin needs to be injected or can be skipped.
     */
    @MainActor
    func accept(
        _ visitor: JavaScriptPluginVisitor,
        _ host: CottonBase.Host,
        _ canInject: Bool,
        _ handler: WKScriptMessageHandler
    ) throws
}

extension JavaScriptPlugin {
    @MainActor
    public func accept(
        _ visitor: JavaScriptPluginVisitor,
        _ host: CottonBase.Host,
        _ canInject: Bool,
        _ handler: WKScriptMessageHandler
    ) throws {
        guard visitor.canVisit(self, host, canInject, handler) else {
            return
        }
        try visitor.visit(self, handler)
    }
}

public extension JavaScriptPlugin {
    static func == (lhs: any JavaScriptPlugin, rhs: any JavaScriptPlugin) -> Bool {
        return lhs.jsFileName == rhs.jsFileName
            && lhs.messageHandlerName == rhs.messageHandlerName
            && lhs.isMainFrameOnly == rhs.isMainFrameOnly
            && lhs.hostKeyword == rhs.hostKeyword
            && lhs.scriptString(true) == rhs.scriptString(true)
    }
}
