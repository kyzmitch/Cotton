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
        case singleVideoNode = "singleVideoNode"
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
                print("JS Instagram log: \(value as! String)")
            case .videoNodes?:
                guard let jsonObject = Data.dataFrom(value) else {
                    break
                }
                do {
                    let decoded = try JSONDecoder().decode([InstagramVideoNode].self, from: jsonObject)
                    delegate?.didReceiveVideoNodes(decoded)
                } catch {
                    print("failed decode video nodes array: \(error)")
                }
            case .singleVideoNode?:
                guard let jsonObject = Data.dataFrom(value) else {
                    break
                }
                do {
                    let decoded = try JSONDecoder().decode(InstagramVideoNode.self, from: jsonObject)
                    delegate?.didReceiveVideoNodes([decoded])
                } catch {
                    print("failed decode single video node: \(error)")
                }
            default:
                print("unexpected key \(key)")
            }
        }
    }
}
