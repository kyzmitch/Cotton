//
//  T4Handler.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 4/19/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import WebKit

public protocol T4ContentDelegate: class {
    func didReceiveVideo(_ video: T4Video)
}

public struct T4ContentPlugin: CottonJSPlugin {
    public let handler: WKScriptMessageHandler

    public let delegate: PluginHandlerDelegateType

    public let jsFileName: String = "t4"

    public let messageHandlerName: String = "t4Handler"

    public let hostKeyword: String = "4tube"

    public func setEnableJsString(_ enable: Bool) -> String {
        return "__cotton__.t4.setEnabled(\(enable ? "true" : "false"));"
    }

    public let isMainFrameOnly: Bool = true

    public init?(delegate: PluginHandlerDelegateType) {
        guard case let .t4(actualDelegate) = delegate else {
            assertionFailure("failed to create object")
            return nil
        }
        self.delegate = delegate
        handler = T4Handler(actualDelegate)
    }

    public init?(anyProtocol: Any) {
        guard let t4Delegate = anyProtocol as? T4ContentDelegate else {
            return nil
        }
        delegate = .t4(t4Delegate)
        handler = T4Handler(t4Delegate)
    }
}

final class T4Handler: NSObject {
    private weak var delegate: T4ContentDelegate?
    init(_ delegate: T4ContentDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    private override init() {
        super.init()
    }
}

fileprivate extension T4Handler {
    enum MessageKey: String {
        case log = "log"
        case video = "video"
    }
}

extension T4Handler: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let args = message.body as? [String: Any] else {
            print("\(#function) message.body has unexpected format")
            return
        }

        for (key, value) in args {
            switch MessageKey(rawValue: key) {
            case .log? where value is String:
                print("JS T4 log: \(value as! String)")
            case .video?:
                guard let jsonObject = Data.dataFrom(value) else {
                    break
                }
                do {
                    let decoded = try JSONDecoder().decode(T4Video.self, from: jsonObject)
                    delegate?.didReceiveVideo(decoded)
                } catch {
                    print("failed decode videos: \(error)")
                }
            default:
                print("unexpected key \(key)")
            }
        }
    }
}
