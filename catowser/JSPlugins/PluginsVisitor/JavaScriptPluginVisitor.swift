//
//  JavaScriptPluginVisitor.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 6/4/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import CoreHttpKit

/// Will be used for `WKUserContentController` because it is actually the only possible visitor
public protocol JavaScriptPluginVisitor: AnyObject {
    /**
     Determines if specific plugin can be used on specific host
    
     - Parameters:
        - plugin JavaScript plugin
        - host hostname from the URL, can be used to determine if plugin is specific to web site
        - needsInject A boolean value which should be used as a top level check. Describes feature availability.
     */
    func canVisit(_ plugin: JavaScriptPlugin, _ host: Host, _ needsInject: Bool) -> Bool
    /**
     Uses specific plugin in a visitor.
     
     - Parameters:
        - plugin JavaScript plugin
     */
    func visit(_ plugin: JavaScriptPlugin) throws
}
