//
//  WebViewMocks.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 10/5/22.
//  Copyright © 2022 Cotton (former Catowser). All rights reserved.
//

import CottonPlugins

@MainActor
final class MockedWebViewWithError: JavaScriptEvaluateble {
    func evaluateJavaScriptV2(
        _ javaScriptString: String,
        completionHandler: (@MainActor @Sendable (Any?, (any Error)?) -> Void)?
    ) {
        struct WebViewJSEvaluationError: Error {}
        completionHandler?(nil, WebViewJSEvaluationError())
    }

    func evaluateJavaScriptV1(
        _ javaScriptString: String,
        completionHandler: ((Any?, Error?) -> Void)?
    ) {
        struct WebViewJSEvaluationError: Error {}
        completionHandler?(nil, WebViewJSEvaluationError())
    }
}
