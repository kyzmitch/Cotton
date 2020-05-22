//
//  WebViewJSPluginsFacade.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 18/03/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import WebKit
import HttpKit
#if canImport(Combine)
import Combine
#endif
import ReactiveSwift

fileprivate extension String {
    static let locationHREF: String = "window.location.href"
}

public protocol JavaScriptEvaluateble: class {
    func evaluateJavaScript(_ javaScriptString: String, completionHandler: ((Any?, Error?) -> Void)?)
}

public final class WebViewJSPluginsFacade {
    private let plugins: [CottonJSPlugin]

    public init?(_ plugins: [CottonJSPlugin]) {
        guard plugins.count != 0 else {
            assertionFailure("Can't initialize object with empty plugins list")
            return nil
        }
        self.plugins = plugins
    }

    public func visit(_ userContentController: WKUserContentController) {
        for plugin in plugins {
            do {
                if plugin is BasePlugin {
                    let wkScript1 = try JSPluginFactory.shared.script(for: plugin,
                                                                      with: .atDocumentStart,
                                                                      isMainFrameOnly: true)
                    let wkScript2 = try JSPluginFactory.shared.script(for: plugin,
                                                                      with: .atDocumentEnd,
                                                                      isMainFrameOnly: true)
                    let wkScript3 = try JSPluginFactory.shared.script(for: plugin,
                                                                      with: .atDocumentStart,
                                                                      isMainFrameOnly: false)
                    let wkScript4 = try JSPluginFactory.shared.script(for: plugin,
                                                                      with: .atDocumentEnd,
                                                                      isMainFrameOnly: false)
                    userContentController.addUserScript(wkScript1)
                    userContentController.addUserScript(wkScript2)
                    userContentController.addUserScript(wkScript3)
                    userContentController.addUserScript(wkScript4)
                    
                    userContentController.removeScriptMessageHandler(forName: plugin.messageHandlerName)
                    userContentController.add(plugin.handler, name: plugin.messageHandlerName)
                } else {
                    let wkScript = try JSPluginFactory.shared.script(for: plugin,
                                                                     with: .atDocumentStart,
                                                                     isMainFrameOnly: plugin.isMainFrameOnly)
                    userContentController.addUserScript(wkScript)
                    userContentController.removeScriptMessageHandler(forName: plugin.messageHandlerName)
                    userContentController.add(plugin.handler, name: plugin.messageHandlerName)
                }
            } catch {
                print("\(#function) failed to load plugin \(plugin.jsFileName)")
            }
        }
    }

    public func enablePlugins(for webView: JavaScriptEvaluateble, with host: HttpKit.Host) {
        plugins
            .filter { !$0.hostKeyword.isEmpty || $0.messageHandlerName == .basePluginHName}
            .compactMap { $0.scriptString(host.rawValue.contains($0.hostKeyword))}
            .forEach { webView.evaluate(jsScript: $0)}
    }
}

extension JavaScriptEvaluateble {
    func evaluate(jsScript: String) {
        // swiftlint:disable:next line_length
        // https://github.com/WebKit/webkit/blob/39a299616172a4d4fe1f7aaf573b41020a1d7358/Source/WebKit/UIProcess/API/Cocoa/WKWebView.mm#L1009
        evaluateJavaScript(jsScript, completionHandler: {(something, error) in
            if let err = error {
                print("Error evaluating JavaScript: \(err)")
            } else if let thing = something {
                print("Received value after evaluating: \(thing)")
            }
        })
    }
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func evaluatePublisher(jsScript: String) -> AnyPublisher<Any, Error> {
        let p = Future<Any, Error> { [weak self] (promise) in
            guard let self = self else {
                promise(.failure(JSPluginsError.zombiError))
                return
            }
            self.evaluateJavaScript(jsScript) { (something, error) in
                if let realError = error {
                    promise(.failure(realError))
                    return
                }
                guard let anyResult = something else {
                    promise(.failure(JSPluginsError.nilJSEvaluationResult))
                    return
                }
                promise(.success(anyResult))
            }
        }
        
        return Deferred {
            return p
        }.eraseToAnyPublisher()
    }
    
    func rxEvaluate(jsScript: String) -> SignalProducer<Any, Error> {
        let producer: SignalProducer<Any, Error> = .init { [weak self] (observer, _) in
            guard let self = self else {
                observer.send(error: JSPluginsError.zombiError)
                return
            }
            self.evaluateJavaScript(jsScript) { (something, error) in
                if let realError = error {
                    observer.send(error: realError)
                    return
                }
                guard let anyResult = something else {
                    observer.send(error: JSPluginsError.nilJSEvaluationResult)
                    return
                }
                observer.send(value: anyResult)
                observer.sendCompleted()
            }
        }
        return producer
    }
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func titlePublisher() -> AnyPublisher<String, Error> {
        typealias StringResult = Result<String, Error>
        return evaluatePublisher(jsScript: "document.title").flatMap { (anyResult) -> StringResult.Publisher in
            guard let documentTitle = anyResult as? String else {
                return StringResult.Publisher(.failure(JSPluginsError.jsEvaluationIsNotString))
            }
            return StringResult.Publisher(.success(documentTitle))
        }.eraseToAnyPublisher()
    }
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func finalURLPublisher() -> AnyPublisher<URL, Error> {
        typealias URLResult = Result<URL, Error>
        // If we have JavaScript blocked, these will be empty.
        return evaluatePublisher(jsScript: .locationHREF).flatMap { (anyResult) -> URLResult.Publisher in
            guard let urlString = anyResult as? String else {
                return URLResult.Publisher(.failure(JSPluginsError.jsEvaluationIsNotString))
            }
            guard let url = URL(string: urlString) else {
                return URLResult.Publisher(.failure(JSPluginsError.jsEvaluationIsNotURL))
            }
            return URLResult.Publisher(.success(url))
        }.eraseToAnyPublisher()
    }
    
    public func rxFinalURL() -> SignalProducer<URL, Error> {
        return rxEvaluate(jsScript: .locationHREF)
            .flatMap(.latest) { (anyResult) -> SignalProducer<URL, Error> in
                guard let urlString = anyResult as? String else {
                    return .init(error: JSPluginsError.jsEvaluationIsNotString)
                }
                guard let url = URL(string: urlString) else {
                    return .init(error: JSPluginsError.jsEvaluationIsNotURL)
                }
                return .init(value: url)
        }
    }
}

enum JSPluginsError: LocalizedError {
    case zombiError
    case nilJSEvaluationResult
    case jsEvaluationIsNotString
    case jsEvaluationIsNotURL
}

struct EvalError: Error {}
