//
//  WebViewVmJSPlugins+DoHCombineTests.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 1/11/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import XCTest
@testable import CoreCatowser
import HttpKit
import CottonCoreBaseKit
import WebKit

final class WebViewVmJSPluginsDoHCombineTests: WebViewVMFixture {
    
    override func setUpWithError() throws {
        exampleIpAddress = "100.0.12.7"
        try super.setUpWithError()
        webViewContext = .init(doh: true, js: true, nativeAppRedirect: false, asyncApiType: .combine)
        settings = .init(isPrivate: false,
                         blockPopups: true,
                         isJSEnabled: true,
                         canLoadPlugins: false)
    }

    func testChangeJSstateWhenDNSoverHTTPSisEnabled() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, webViewContext)
        vm.load()
        XCTAssertEqual(vm.combineWebPageState.value, .reattachViewObservers)
        // swiftlint:disable:next force_unwrapping
        let urlInfoV1 = URLInfo(urlV1!)!
        let expectedStateV1: WebViewModelState = .resolvingDN(urlInfoV1, settings)
        XCTAssertEqual(vm.state, expectedStateV1)
        _ = XCTWaiter.wait(for: [expectation(description: "Wait for async domain name resolving")], timeout: 1.0)
        // swiftlint:disable:next force_unwrapping force_try
        let resolvedUrlV1 = try! urlV1!.updatedHost(with: exampleIpAddress!)
        let urlRequestV1 = URLRequest(url: resolvedUrlV1)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV1))
        // swiftlint:disable:next force_unwrapping
        let urlInfoV11: URLInfo = urlInfoV1.withIPAddress(ipAddress: exampleIpAddress!)
        let expectedStateV11: WebViewModelState = .updatingWebView(settings, urlInfoV11)
        XCTAssertEqual(vm.state, expectedStateV11)
        
        let navActionV1 = MockedNavAction(resolvedUrlV1, .other)
        vm.decidePolicy(navActionV1) { policy in
            XCTAssertEqual(policy, .allow)
        }
        vm.finishLoading(resolvedUrlV1, jsSubject)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV1))
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV11))
        
        // JS was already enabled
        
        vm.setJavaScript(jsSubject, true)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV1))
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV11))
        
        // User disables JS
        
        vm.setJavaScript(jsSubject, false)
        let expectedSettingsV2: Site.Settings = settings.withChanged(javaScriptEnabled: false)
        let expectedStateV2: WebViewModelState = .updatingJS(expectedSettingsV2, jsSubject, urlInfoV11)
        XCTAssertEqual(vm.state, expectedStateV2)
        
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV1))
        XCTAssertEqual(vm.state, .viewing(expectedSettingsV2, urlInfoV11))
        
        // User enables JS back
        
        vm.setJavaScript(jsSubject, true)
        let expectedSettingsV3: Site.Settings = expectedSettingsV2.withChanged(javaScriptEnabled: true)
        let expectedStateV3: WebViewModelState = .updatingJS(expectedSettingsV3, jsSubject, urlInfoV11)
        XCTAssertEqual(vm.state, expectedStateV3)
        
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV1))
        XCTAssertEqual(vm.state, .viewing(expectedSettingsV3, urlInfoV11))
    }
}
