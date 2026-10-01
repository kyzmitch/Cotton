//
//  BaseJSHandler.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 30/04/2019.
//  Copyright © 2019 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import WebKit
import CottonLogs

/// Handler for the base java script based web site,
///
/// should be main actor because it confirms to `WKScriptMessageHandler`.
/// Also, it should subclass from NSObject because confirmation to `WKScriptMessageHandler`
/// is based on `NSObjectProtocol`.
@MainActor final class BaseJSHandler: NSObject {
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
            CottonLogger.plugins.warning("\(#function) message.body has unexpected format")
            return
        }

        for (key, value) in args {
            switch MessageKey(rawValue: key) {
            case .log? where value is String:
                // swiftlint:disable:next force_cast
                CottonLogger.plugins.info("JS Base log: \(value as! String)")
            case .html?:
                if !handleHtmlKey(value) {
                    break
                }
            case .DOMVideoTags?:
                if !handleDOMVideoTags(value) {
                    break
                }
            default:
                CottonLogger.plugins.warning("unexpected key \(key)")
            }
        }
    }
}

private extension BaseJSHandler {
    func handleHtmlKey(_ value: Any) -> Bool {
        guard let jsonObject = Data.dataFrom(value) else {
            return false
        }
        let htmlContentMsg: HTMLContentMessage
        do {
            htmlContentMsg = try JSONDecoder().decode(HTMLContentMessage.self, from: jsonObject)
        } catch {
            CottonLogger.plugins.error("HTML content is corrupted: \(error)")
            return false
        }
        // now need to parse to find video tags and extract urls
        guard let videoTags = try? HTMLVideoTagsContainer(htmlMessage: htmlContentMsg) else {
            return false
        }
        delegate?.didReceiveVideoTags(videoTags.videoTags)
        return true
    }

    func handleDOMVideoTags(_ value: Any) -> Bool {
        guard let jsonObject = Data.dataFrom(value) else {
            return false
        }
        do {
            let decoded = try JSONDecoder().decode([HTMLVideoTag].self, from: jsonObject)
            CottonLogger.plugins.info("DOM video tags: \(decoded.count)")
        } catch {
            CottonLogger.plugins.error("failed decode DOM videos: \(error)")
        }
        return true
    }
}
