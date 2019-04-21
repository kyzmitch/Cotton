//
//  t4Handler.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 4/19/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import WebKit

public struct t4ContentPlugin: CottonJSPlugin {
    public let handler: WKScriptMessageHandler

    public let delegate: PluginHandlerDelegateType

    public let jsFileName: String = "t4"

    public let messageHandlerName: String = "t4Handler"

    public let isMainFrameOnly: Bool = true

    public init?(delegate: PluginHandlerDelegateType) {
        guard case .t4 = delegate else {
            assertionFailure("failed to create object")
            return nil
        }
        self.delegate = delegate
        handler = T4Handler()
    }

    public init?(anyProtocol: Any) {
        delegate = .t4
        handler = T4Handler()
    }
}

public final class T4Handler: NSObject {
}

extension T4Handler: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
}
