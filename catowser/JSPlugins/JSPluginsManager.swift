//
//  JSPluginsManager.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 18/03/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import WebKit

public final class JSPluginsManager {
    static let shared = JSPluginsManager()

    private var activePlugins = Set<JSPluginName>()

    private init() {
        activePlugins.insert(.instagram)
        activePlugins.insert(.instagram)
    }

    public func visit(_ userContentController: WKUserContentController) {

    }
}
