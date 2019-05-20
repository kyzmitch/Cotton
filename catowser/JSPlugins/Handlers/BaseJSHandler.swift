//
//  BaseJSHandler.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 30/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import WebKit

public struct BasePlugin: CottonJSPlugin {
    public let jsFileName: String = "__cotton__"

    public let messageHandlerName: String = "cottonHandler"

    /// Should be present on any web site no matter which host is it
    public let hostKeyword: String = ""

    public func setEnableJsString(_ enable: Bool) -> String {
        return ""
    }

    public let isMainFrameOnly: Bool = true

    public let delegate: PluginHandlerDelegateType = .base

    public let handler: WKScriptMessageHandler = BaseJSHandler()

    public init?(delegate: PluginHandlerDelegateType) {}

    public init?(anyProtocol: Any) {}

    public init() {}
}

fileprivate final class BaseJSHandler: NSObject {}

fileprivate extension BaseJSHandler {
    enum MessageKey: String {
        case log = "log"
        case html = "html"
    }
}

extension BaseJSHandler: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let args = message.body as? [String: Any] else {
            print("\(#function) message.body has unexpected format")
            return
        }

        for (key, value) in args {
            switch MessageKey(rawValue: key) {
            case .log? where value is String:
                print("JS Base log: \(value as! String)")
            case .html? where value is String:
                // now need to parse to find video tags and extract urls
                do {
                    let videoTags = try HTMLVideoTagsContainer(html: value as! String)
                    print("video tags: \(videoTags.videoTags.count)")
                } catch {
                    print("failed to parse video tags: \(error)")
                }
                
            default:
                print("unexpected key \(key)")
            }
        }
    }
}
