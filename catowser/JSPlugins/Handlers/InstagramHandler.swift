//
//  InstagramHandler.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 3/18/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import WebKit

public protocol InstagramContentDelegate: class {
    func didReceiveVideoLink(_ url: URL)
}

public final class InstagramHandler: NSObject {
    private weak var delegate: InstagramContentDelegate?
    public init(_ delegate: InstagramContentDelegate) {
        self.delegate = delegate
        super.init()
    }

    private override init() {
        super.init()
    }
}

fileprivate extension InstagramHandler {
    enum MessageKey: String {
        case log = "log"
        case url = "url"
    }
}

extension InstagramHandler: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let args = message.body as? [String: Any] else {
            print("\(#function) message.body has unexpected format")
            return
        }

        for (key, value) in args {
            switch MessageKey(rawValue: key) {
            case .log? where value is String:
                print("\(value as! String)")
            case .url?:
                if let urlString = value as? String, let url = URL(string: urlString) {
                    print("received url: \(url.absoluteString)")
                }
                else {
                    print("url key value has incorrect format")
                }
            default:
                print("unexpected key \(key)")
            }
        }
    }
}
