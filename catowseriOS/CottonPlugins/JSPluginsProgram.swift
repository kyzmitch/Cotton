//
//  JSPluginsProgram.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 08/10/2022.
//  Copyright © 2022 Cotton (former Catowser). All rights reserved.
//

import Foundation
import WebKit
import CottonBase

/// Can be sendable, but it is not required now
public final class HandlablePlugin {
    public let plugin: any JavaScriptPlugin
    public let handler: WKScriptMessageHandler
    
    public init(
        plugin: any JavaScriptPlugin,
        handler: WKScriptMessageHandler
    ) {
        self.plugin = plugin
        self.handler = handler
    }
}

/// Should be main actor because it stores wk handlers which are marked as
/// main actors in the sdk.
@MainActor public protocol JSPluginsProgram: AnyObject, Sendable {
    var plugins: [HandlablePlugin] { get }

    func inject(to visitor: WKUserContentController, context: CottonBase.Host, canInject: Bool)
    func enable(on webView: JavaScriptEvaluateble, context: CottonBase.Host, jsEnabled: Bool)
}
