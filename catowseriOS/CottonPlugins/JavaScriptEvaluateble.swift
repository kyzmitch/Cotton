//
//  JavaScriptEvaluateble.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 5/30/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation
import Combine
@preconcurrency import ReactiveSwift

public protocol JavaScriptEvaluateble: AnyObject {
    func evaluateJavaScript(
        _ javaScriptString: String,
        completionHandler: (@MainActor @Sendable (Any?, (any Error)?) -> Void)?
    )
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
                promise(.failure(CottonPluginError.zombiError))
                return
            }
            self.evaluateJavaScript(jsScript) { (something, error) in
                if let realError = error {
                    promise(.failure(realError))
                    return
                }
                guard let anyResult = something else {
                    promise(.failure(CottonPluginError.nilJSEvaluationResult))
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
                observer.send(error: CottonPluginError.zombiError)
                return
            }
            self.evaluateJavaScript(jsScript) { (something, error) in
                if let realError = error {
                    observer.send(error: realError)
                    return
                }
                guard let anyResult = something else {
                    observer.send(error: CottonPluginError.nilJSEvaluationResult)
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
                return StringResult.Publisher(.failure(CottonPluginError.jsEvaluationIsNotString))
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
                return URLResult.Publisher(.failure(CottonPluginError.jsEvaluationIsNotString))
            }
            guard let url = URL(string: urlString) else {
                return URLResult.Publisher(.failure(CottonPluginError.jsEvaluationIsNotURL))
            }
            return URLResult.Publisher(.success(url))
        }.eraseToAnyPublisher()
    }

    public func rxFinalURL() -> SignalProducer<URL, Error> {
        return rxEvaluate(jsScript: .locationHREF)
            .flatMap(.latest) { (anyResult) -> SignalProducer<URL, Error> in
                guard let urlString = anyResult as? String else {
                    return .init(error: CottonPluginError.jsEvaluationIsNotString)
                }
                guard let url = URL(string: urlString) else {
                    return .init(error: CottonPluginError.jsEvaluationIsNotURL)
                }
                return .init(value: url)
            }
    }
}

fileprivate extension String {
    static let locationHREF: String = "window.location.href"
}
