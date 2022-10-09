//
//  JSPluginsProgram.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 08/10/2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import WebKit
import CoreHttpKit

public protocol JSPluginsProgram: AnyObject, Equatable {
    var plugins: [any JavaScriptPlugin] { get }
    
    func inject(to visitor: WKUserContentController, context: Host, canInject: Bool)
    func enable(on webView: JavaScriptEvaluateble, context: Host, jsEnabled: Bool)
}
