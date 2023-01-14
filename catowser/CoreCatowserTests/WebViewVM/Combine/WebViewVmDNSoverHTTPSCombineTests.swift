//
//  WebViewVmDNSoverHTTPSCombineTests.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 10/7/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import XCTest
@testable import CoreCatowser
import HttpKit
import CoreHttpKit
import WebKit

final class WebViewVmDNSoverHTTPSCombineTests: WebViewVMFixture {
    
    override func setUpWithError() throws {
        exampleIpAddress = "100.0.12.7"
        try super.setUpWithError()
        webViewContext = .init(doh: true, js: false, nativeAppRedirect: false, asyncApiType: .combine)
    }
    
    func testInit() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, webViewContext)
        XCTAssertEqual(vm.host.content, Host.Content.domainname)
        XCTAssertEqual(vm.host.rawString, exampleDomainName.rawString)
        XCTAssertEqual(vm.urlInfo, exampleURLInfo)
        XCTAssertEqual(vm.settings, settings)
        XCTAssertEqual(vm.currentURL, urlV1)
        XCTAssertNotEqual(vm.currentURL, wrongUrlV1)
        XCTAssertNotEqual(vm.currentURL, wrongUrlV2)
        XCTAssertNotEqual(vm.currentURL, wrongUrlV3)
        XCTAssertNil(vm.nativeAppDomainNameString)
        XCTAssertEqual(vm.combineWebPageState.value, .recreateView(false))
        XCTAssertEqual(vm.state, .initialized(exampleSite))
    }
    
    func testLoad() throws {
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
    }
    
    func testDisableDoH() throws {
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
        
        // Now can disable DNS over HTTPs, it was enabled initially in context
        
        webViewContext.setDNSoverHTTPs(false)
        vm.setDoH(false)
        // swiftlint:disable:next force_unwrapping
        let urlRequestV11 = URLRequest(url: urlV1!)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV11))
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlInfoV11))
        webViewContext.setDNSoverHTTPs(true)
    }
    
    func testEnableDoH() throws {
        webViewContext = .init(doh: false, js: false, nativeAppRedirect: false, asyncApiType: .combine)
        
        // Usual load without DoH
        
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, webViewContext)
        vm.load()
        
        // This is a bad path case, user has to call `finishLoading`
        // to complete the load request and have a final state which is `.viewing`
        
        // swiftlint:disable:next force_unwrapping
        let urlInfoV1: URLInfo = .init(urlV1!)!
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlInfoV1.urlRequest))
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlInfoV1))
        
        // swiftlint:disable:next force_unwrapping
        let navActionV1 = MockedNavAction(urlV1!, .other)
        vm.decidePolicy(navActionV1) { policy in
            XCTAssertEqual(policy, .allow)
        }
        
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlInfoV1.urlRequest))
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV1))
        
        // Now can enable DNS over HTTPs, it was disabled initially in context
        
        webViewContext.setDNSoverHTTPs(true)
        vm.setDoH(true)
        _ = XCTWaiter.wait(for: [expectation(description: "Wait for async domain name resolving")], timeout: 1.0)
        // swiftlint:disable:next force_unwrapping force_try
        let resolvedUrlV1 = try! urlV1!.updatedHost(with: exampleIpAddress!)
        let urlRequestV11 = URLRequest(url: resolvedUrlV1)
        // swiftlint:disable:next force_unwrapping
        let urlInfoV11: URLInfo = urlInfoV1.withIPAddress(ipAddress: exampleIpAddress!)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV11))
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlInfoV11))
        webViewContext.setDNSoverHTTPs(true)
    }
}
