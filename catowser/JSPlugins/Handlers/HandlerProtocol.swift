//
//  HandlerProtocol.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 19/03/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import WebKit

typealias JSPluginHandler = WKScriptMessageHandler & Hashable
