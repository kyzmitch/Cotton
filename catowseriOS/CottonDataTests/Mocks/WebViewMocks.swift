//
//  WebViewMocks.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 10/5/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import JSPlugins

final class MockedWebViewWithError: JavaScriptEvaluateble {
    func evaluateJavaScript(_ javaScriptString: String, completionHandler: ((Any?, Error?) -> Void)?) {
        struct WebViewJSEvaluationError: Error {}
        completionHandler?(nil, WebViewJSEvaluationError())
    }
}
