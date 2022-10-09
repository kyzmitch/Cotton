//
//  BasePlugin.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 5/30/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import WebKit

public protocol BasePluginContentDelegate: AnyObject {
    func didReceiveVideoTags(_ tags: [HTMLVideoTag])
}

public struct BasePlugin: JavaScriptPlugin {
    public let jsFileName: String = "__cotton__"

    public let messageHandlerName: String = .basePluginHName

    /// Should be present on any web site no matter which host is it
    public let hostKeyword: String? = nil

    public func scriptString(_ enable: Bool) -> String? {
        // always should work, no need to enable it
        return nil
    }

    public let isMainFrameOnly: Bool = true

    public let handler: WKScriptMessageHandler

    public init?(delegate: PluginHandlerDelegateType) {
        guard case let .base(actualDelegate) = delegate else {
            assertionFailure("failed to create BasePlugin because of wrong delegate")
            return nil
        }
        handler = BaseJSHandler(actualDelegate)
    }

    public init?(anyProtocol: Any) {
        guard let baseDelegate = anyProtocol as? BasePluginContentDelegate else {
            return nil
        }
        handler = BaseJSHandler(baseDelegate)
    }
}

extension String {
    /// Always should be enabled
    static let basePluginHName = "cottonHandler"
}

extension BasePlugin: Equatable {
    public static func == (lhs: BasePlugin, rhs: BasePlugin) -> Bool {
        return lhs.jsFileName == rhs.jsFileName
        && lhs.messageHandlerName == rhs.messageHandlerName
        && lhs.hostKeyword == rhs.hostKeyword
        && lhs.isMainFrameOnly == rhs.isMainFrameOnly
    }
}
