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
    func didReceiveVideoNodes(_ nodes: [InstagramVideoNode])
}

public struct InstagramContentPlugin: CottonJSPlugin {
    public let handler: WKScriptMessageHandler

    public let delegate: PluginHandlerDelegateType

    public let jsFileName: String = "ig"

    public let messageHandlerName: String = "igHandler"

    public let isMainFrameOnly: Bool = false

    public init?(delegate: PluginHandlerDelegateType) {
        guard case let .instagram(actualDelegate) = delegate else {
            assertionFailure("failed to create object")
            return nil
        }
        self.delegate = delegate
        handler = InstagramHandler(actualDelegate)
    }

    public init?(anyProtocol: Any) {
        guard let igDelegate = anyProtocol as? InstagramContentDelegate else {
            return nil
        }
        delegate = .instagram(igDelegate)
        handler = InstagramHandler(igDelegate)
    }
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
        case videoTags = "videoTags"
        case videoNodes = "videoNodes"
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
                print("JS log: \(value as! String)")
            case .videoNodes?:
                guard let jsonObject = dataFrom(value) else {
                    break
                }
                do {
                    let decoded = try JSONDecoder().decode(InstagramVideoArray.self, from: jsonObject)
                    if decoded.nodes.count > 0 {
                        delegate?.didReceiveVideoNodes(decoded.nodes)
                    } else {
                        print("no any video node was found during decoding")
                    }
                } catch {
                    print("failed decode video nodes array: \(error)")
                }
            default:
                print("unexpected key \(key)")
            }
        }
    }
    
    func dataFrom(_ value: Any) -> Data? {
        guard let jsArrayString =  value as? String else {
            print("js value is not a string")
            return nil
        }
        guard let jsonObject = jsArrayString.data(using: .utf8, allowLossyConversion: true) else {
            print("failed to convert string to data")
            return nil
        }
        return jsonObject
    }
}
