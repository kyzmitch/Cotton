//
//  t4Handler.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 4/19/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import WebKit

public struct t4ContentPlugin: CottonJSPlugin {
    public let handler: WKScriptMessageHandler

    public let delegate: PluginHandlerDelegateType

    public let jsFileName: String = "t4"

    public let messageHandlerName: String = "t4Handler"

    public let isMainFrameOnly: Bool = true

    public init?(delegate: PluginHandlerDelegateType) {
        guard case .t4 = delegate else {
            assertionFailure("failed to create object")
            return nil
        }
        self.delegate = delegate
        handler = T4Handler()
    }

    public init?(anyProtocol: Any) {
        delegate = .t4
        handler = T4Handler()
    }
}

public final class T4Handler: NSObject {
}

fileprivate extension T4Handler {
    enum MessageKey: String {
        case log = "log"
        case videos = "videos"
    }
}

extension T4Handler: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let args = message.body as? [String: Any] else {
            print("\(#function) message.body has unexpected format")
            return
        }

        for (key, value) in args {
            switch MessageKey(rawValue: key) {
            case .log? where value is String:
                print("JS log: \(value as! String)")
            case .videos?:
                guard let jsonObject = Data.dataFrom(value) else {
                    break
                }
                do {
                    let decoded = try JSONDecoder().decode(T4VideoDictionary.self, from: jsonObject)
                } catch {
                    print("failed decode videos: \(error)")
                }
            default:
                print("unexpected key \(key)")
            }
        }
    }
}
