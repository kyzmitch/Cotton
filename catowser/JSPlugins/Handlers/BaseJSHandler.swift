//
//  BaseJSHandler.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 30/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import WebKit

public protocol BasePluginContentDelegate: class {
    func didReceiveVideoTags(_ tags: [HTMLVideoTag])
}

public struct BasePlugin: CottonJSPlugin {
    public let jsFileName: String = "__cotton__"

    public let messageHandlerName: String = "cottonHandler"

    /// Should be present on any web site no matter which host is it
    public let hostKeyword: String = ""

    public func setEnableJsString(_ enable: Bool) -> String {
        return ""
    }

    public let isMainFrameOnly: Bool = true

    public let handler: WKScriptMessageHandler

    public init?(delegate: PluginHandlerDelegateType) {
        guard case let .base(actualDelegate) = delegate else {
            assertionFailure("failed to create BasePlugin because of wrong delegate")
            return nil
        }
        handler = BaseJSHandler(actualDelegate)
    }

    public init?(anyProtocol: Any) {
        guard let baseDelegate = anyProtocol as? BasePluginContentDelegate else {
            return nil
        }
        handler = BaseJSHandler(baseDelegate)
    }
}

fileprivate final class BaseJSHandler: NSObject {
    private weak var delegate: BasePluginContentDelegate?

    init(_ delegate: BasePluginContentDelegate) {
        self.delegate = delegate
        super.init()
    }

    private override init() {
        super.init()
    }
}

fileprivate extension BaseJSHandler {
    enum MessageKey: String {
        case log = "log"
        case html = "html"
        case DOMVideoTags = "domVideos"
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
                // swiftlint:disable:next force_cast
                print("JS Base log: \(value as! String)")
            case .html? where value is String:
                // now need to parse to find video tags and extract urls
                do {
                    // swiftlint:disable:next force_cast
                    let videoTags = try HTMLVideoTagsContainer(html: value as! String)
                    delegate?.didReceiveVideoTags(videoTags.videoTags)
                } catch {
                    print("failed to parse video tags: \(error)")
                }
            case .DOMVideoTags?:
                guard let jsonObject = Data.dataFrom(value) else {
                    break
                }
                do {
                    let decoded = try JSONDecoder().decode([HTMLVideoTag].self, from: jsonObject)
                    print("DOM video tags: \(decoded.count)")
                } catch {
                    print("failed decode DOM videos: \(error)")
                }
            default:
                print("unexpected key \(key)")
            }
        }
    }
}
