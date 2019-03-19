//
//  InstagramHandler.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 3/18/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import WebKit

public final class InstagramHandler: NSObject {
    
}

extension InstagramHandler: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("JS Instagram handler: \(message.name) \(message.body)")

        guard let args = message.body as? [String: AnyObject] else {
            print("message.body is empty")
            return
        }

        // switch message.name

    }
}
