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

public protocol JSPluginsProgram: AnyObject, Equatable {
    var plugins: [any JavaScriptPlugin] { get }
    
    func inject(to visitor: WKUserContentController, context: CottonBase.Host, canInject: Bool)
    func enable(on webView: JavaScriptEvaluateble, context: CottonBase.Host, jsEnabled: Bool)
}
