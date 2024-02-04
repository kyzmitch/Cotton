//
//  InstagramContentPlugin.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 5/30/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation
import WebKit

public protocol InstagramContentDelegate: AnyObject {
    func didReceiveVideoNodes(_ nodes: [InstagramVideoNode])
}

public struct InstagramContentPlugin: JavaScriptPlugin {
    public let handler: WKScriptMessageHandler

    public let jsFileName: String = "ig"

    public let messageHandlerName: String = "igHandler"

    public let hostKeyword: String? = "instagram"

    public func scriptString(_ enable: Bool) -> String? {
        return "__cotton__.ig.setEnabled(\(enable ? "true" : "false"));"
    }

    public let isMainFrameOnly: Bool = true

    public init?(delegate: PluginHandlerDelegateType) {
        guard case let .instagram(actualDelegate) = delegate else {
            assertionFailure("failed to create object")
            return nil
        }
        handler = InstagramHandler(actualDelegate)
    }

    public init?(anyProtocol: Any) {
        guard let igDelegate = anyProtocol as? InstagramContentDelegate else {
            return nil
        }
        handler = InstagramHandler(igDelegate)
    }
}

extension InstagramContentPlugin: Equatable {
    public static func == (lhs: InstagramContentPlugin, rhs: InstagramContentPlugin) -> Bool {
        return lhs.jsFileName == rhs.jsFileName
            && lhs.messageHandlerName == rhs.messageHandlerName
            && lhs.hostKeyword == rhs.hostKeyword
            && lhs.isMainFrameOnly == rhs.isMainFrameOnly
    }
}
