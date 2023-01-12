//
//  WebViewVMConcurrencyTests.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 1/11/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import XCTest
@testable import CoreCatowser
import HttpKit
import CoreHttpKit
import WebKit

final class WebViewVMConcurrencyTests: WebViewVMFixture {
    override func setUpWithError() throws {
        try super.setUpWithError()
        webViewContext = .init(doh: false, js: false, asyncApiType: .asyncAwait)
    }
    
    func testLoad() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, webViewContext)
        vm.load()
        
        // This is a bad path case, user has to call `finishLoading`
        // to complete the load request and have a final state which is `.viewing`
        
        // swiftlint:disable:next force_unwrapping
        let urlInfoV1: URLInfo = .init(urlV1!)!
        let webPageState1 = try awaitPublisherValue(vm.webPageStatePublisher)
        XCTAssertEqual(webPageState1, .load(urlInfoV1.urlRequest))
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlInfoV1))
        
        // swiftlint:disable:next force_unwrapping
        let navActionV1 = MockedNavAction(urlV1!, .other)
        vm.decidePolicy(navActionV1) { policy in
            XCTAssertEqual(policy, .allow)
        }
        
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        let webPageState2 = try awaitPublisherValue(vm.webPageStatePublisher)
        XCTAssertEqual(webPageState2, .load(urlInfoV1.urlRequest))
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV1))
    }
}
