//
//  MockSearchBarContext.swift
//  CottonViewModelsTests
//

import CoreBrowser
import CottonViewModels

/// Controllable SearchBarContext for SearchBarViewModelImpl tests.
final class MockSearchBarContext: SearchBarContext, @unchecked Sendable {
    var blockPopups: Bool
    var isJSEnabledValue: Bool
    var webAutocompletionSource: WebAutoCompletionSource

    init(
        blockPopups: Bool = false,
        isJSEnabled: Bool = true,
        webAutocompletionSource: WebAutoCompletionSource = .google
    ) {
        self.blockPopups = blockPopups
        self.isJSEnabledValue = isJSEnabled
        self.webAutocompletionSource = webAutocompletionSource
    }

    var isJSEnabled: Bool {
        get async { isJSEnabledValue }
    }

    var webAutocompletionSourceValue: WebAutoCompletionSource {
        get async { webAutocompletionSource }
    }
}
