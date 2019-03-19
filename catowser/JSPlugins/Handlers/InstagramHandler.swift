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

fileprivate extension InstagramHandler {
    enum MessageKey: String {
        case log = "log"
        case url = "url"
    }
}

extension InstagramHandler: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let args = message.body as? [String: String] else {
            print("\(#function) message.body has unexpected format")
            return
        }

        for (key, value) in args {
            switch MessageKey(rawValue: key) {
            case .log?:
                print("\(value)")
            case .url?:
                guard let url = URL(string: value) else {
                    print("url key value has incorrect format")
                    continue
                }
                print("received url: \(url.absoluteString)")
            default:
                print("unexpected key \(key)")
            }
        }
    }
}
