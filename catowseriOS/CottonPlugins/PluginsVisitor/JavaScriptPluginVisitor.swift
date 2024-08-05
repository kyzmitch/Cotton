//
//  JavaScriptPluginVisitor.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 6/4/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation
import CottonBase
import WebKit

/// Will be used for `WKUserContentController` because it is actually the only possible visitor
@MainActor
public protocol JavaScriptPluginVisitor: AnyObject {
    /**
     Determines if specific plugin can be used on specific host

     - Parameters:
     - plugin JavaScript plugin
     - host hostname from the URL, can be used to determine if plugin is specific to web site
     - canInject A boolean value which should be used as a top level check. Describes feature availability.
     - handler Shouled be stored separately from the plugin because it is a reference type.
     */
    func canVisit(
        _ plugin: any JavaScriptPlugin,
        _ host: CottonBase.Host,
        _ canInject: Bool,
        _ handler: WKScriptMessageHandler
    ) -> Bool
    /**
     Uses specific plugin in a visitor.

     - Parameters:
     - plugin JavaScript plugin
     */
    func visit(
        _ plugin: any JavaScriptPlugin,
        _ handler: WKScriptMessageHandler
    ) throws
}
