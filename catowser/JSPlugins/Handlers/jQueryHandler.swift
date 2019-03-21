//
//  jQueryHandler.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 3/18/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import WebKit

public struct JQueryAjaxLinksPlugin: CottonJSPlugin {
    public let handler: WKScriptMessageHandler

    public let delegate: PluginHandlerDelegate

    public let jsFileName: String = "jquery_ajax"

    public let messageHandlerName: String = "jQueryHandler"

    public let isMainFrameOnly: Bool = true

    public init?(delegate: PluginHandlerDelegate) {
        guard case .jQueryAjax = delegate else {
            assertionFailure("failed to create object")
            return nil
        }
        self.delegate = delegate
        handler = JQueryHandler()
    }
}

public final class JQueryHandler: NSObject {
}

extension JQueryHandler: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
}
