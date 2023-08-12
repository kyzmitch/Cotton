//
//  WebViewVMConcurrencyTests.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 1/11/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import XCTest
@testable import CottonData
import CottonRestKit
import CottonBase
import WebKit

@MainActor
final class WebViewVMConcurrencyTests: WebViewVMFixture {
    override func setUpWithError() throws {
        try super.setUpWithError()
        webViewContext = .init(doh: false, js: false, nativeAppRedirect: false, asyncApiType: .asyncAwait)
    }
    
    func testLoad() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, webViewContext)
        vm.load()
        
        // This is a bad path case, user has to call `finishLoading`
        // to complete the load request and have a final state which is `.viewing`
        
        // swiftlint:disable:next force_unwrapping
        let urlInfoV1: URLInfo = .init(urlV1!)!
        var webPageState = try awaitPublisherValue(vm.webPageStatePublisher)
        XCTAssertEqual(webPageState, .load(urlInfoV1.urlRequest))
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlInfoV1))
        
        // swiftlint:disable:next force_unwrapping
        let navActionV1 = MockedNavAction(urlV1!, .other)
        vm.decidePolicy(navActionV1) { policy in
            XCTAssertEqual(policy, .allow)
        }
        
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        webPageState = try awaitPublisherValue(vm.webPageStatePublisher)
        XCTAssertEqual(webPageState, .load(urlInfoV1.urlRequest))
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV1))
    }
    
    func testLinkActivation() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, webViewContext)
        vm.load()
        // swiftlint:disable:next force_unwrapping
        let urlInfoV1: URLInfo = .init(urlV1!)!
        var webPageState = try awaitPublisherValue(vm.webPageStatePublisher)
        XCTAssertEqual(webPageState, .load(urlInfoV1.urlRequest))
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlInfoV1))
        // swiftlint:disable:next force_unwrapping
        let navActionV1 = MockedNavAction(urlV1!, .other)
        vm.decidePolicy(navActionV1) { policy in
            XCTAssertEqual(policy, .allow)
        }
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        webPageState = try awaitPublisherValue(vm.webPageStatePublisher)
        XCTAssertEqual(webPageState, .load(urlInfoV1.urlRequest))
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV1))
        
        // User taps on a link in web view which already displays some web site
        
        // swiftlint:disable:next force_unwrapping
        let navActionV3 = MockedNavAction(urlV3!, .linkActivated)
        vm.decidePolicy(navActionV3) { policy in
            XCTAssertEqual(policy, .cancel)
        }
        // swiftlint:disable:next force_unwrapping
        let urlDataV3: URLInfo = URLInfo(urlV3!)!
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlDataV3))
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV3!, jsSubject)
        webPageState = try awaitPublisherValue(vm.webPageStatePublisher)
        XCTAssertEqual(webPageState, .load(urlDataV3.urlRequest))
        XCTAssertEqual(vm.state, .viewing(settings, urlDataV3))
    }
    
    func testReload() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, webViewContext)
        vm.load()
        // swiftlint:disable:next force_unwrapping
        let urlInfoV1: URLInfo = .init(urlV1!)!
        var webPageState = try awaitPublisherValue(vm.webPageStatePublisher)
        XCTAssertEqual(webPageState, .load(urlInfoV1.urlRequest))
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlInfoV1))
        
        // swiftlint:disable:next force_unwrapping
        let navActionV1 = MockedNavAction(urlV1!, .other)
        vm.decidePolicy(navActionV1) { policy in
            XCTAssertEqual(policy, .allow)
        }
        
        // User taps on reload before load finish - error in vm state
        vm.reload()
        
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        webPageState = try awaitPublisherValue(vm.webPageStatePublisher)
        XCTAssertEqual(webPageState, .load(urlInfoV1.urlRequest))
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV1))
        
        vm.reload()
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV1))
    }
    
    func testGoBack() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, webViewContext)
        vm.load()
        // swiftlint:disable:next force_unwrapping
        let urlRequestV1 = URLRequest(url: urlV1!)
        var webPageState = try awaitPublisherValue(vm.webPageStatePublisher)
        XCTAssertEqual(webPageState, .load(urlRequestV1))
        // swiftlint:disable:next force_unwrapping
        let urlInfoV1: URLInfo = .init(urlV1!)!
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlInfoV1))
        // swiftlint:disable:next force_unwrapping
        let navActionV1 = MockedNavAction(urlV1!, .other)
        vm.decidePolicy(navActionV1) { policy in
            XCTAssertEqual(policy, .allow)
        }
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        webPageState = try awaitPublisherValue(vm.webPageStatePublisher)
        XCTAssertEqual(webPageState, .load(urlRequestV1))
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV1))
        
        // User taps on a link in web view which already displays some web site
        
        // swiftlint:disable:next force_unwrapping
        let navActionV3 = MockedNavAction(urlV3!, .linkActivated)
        vm.decidePolicy(navActionV3) { policy in
            XCTAssertEqual(policy, .cancel)
        }
        // swiftlint:disable:next force_unwrapping
        let urlRequestV3 = URLRequest(url: urlV3!)
        // swiftlint:disable:next force_unwrapping
        let urlDataV3: URLInfo = .init(urlV3!)!
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlDataV3))
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV3!, jsSubject)
        webPageState = try awaitPublisherValue(vm.webPageStatePublisher)
        XCTAssertEqual(webPageState, .load(urlRequestV3))
        XCTAssertEqual(vm.state, .viewing(settings, urlDataV3))
        
        // User decided to go back
        
        vm.goBack()
        let msg1 = "Have to finish loading after back navigation"
        XCTAssertNotEqual(vm.state, .viewing(settings, urlInfoV1), msg1)
        XCTAssertNotEqual(vm.state, .waitingForNavigation(settings, urlInfoV1))
        XCTAssertEqual(vm.state, .waitingForNavigation(settings, urlDataV3))
        
        // swiftlint:disable:next force_unwrapping
        let navActionV11 = MockedNavAction(urlV1!, .backForward)
        vm.decidePolicy(navActionV11) { policy in
            XCTAssertEqual(policy, .allow)
        }
        
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV1), "New url is expected")
    }
    
    // swiftlint:disable:next function_body_length
    func testGoForward() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, webViewContext)
        vm.load()
        // swiftlint:disable:next force_unwrapping
        let urlRequestV1 = URLRequest(url: urlV1!)
        var webPageState = try awaitPublisherValue(vm.webPageStatePublisher)
        XCTAssertEqual(webPageState, .load(urlRequestV1))
        // swiftlint:disable:next force_unwrapping
        let urlInfoV1: URLInfo = .init(urlV1!)!
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlInfoV1))
        // swiftlint:disable:next force_unwrapping
        let navActionV1 = MockedNavAction(urlV1!, .other)
        vm.decidePolicy(navActionV1) { policy in
            XCTAssertEqual(policy, .allow)
        }
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        webPageState = try awaitPublisherValue(vm.webPageStatePublisher)
        XCTAssertEqual(webPageState, .load(urlRequestV1))
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV1))
        
        // User taps on a link in web view which already displays some web site
        
        // swiftlint:disable:next force_unwrapping
        let navActionV3 = MockedNavAction(urlV3!, .linkActivated)
        vm.decidePolicy(navActionV3) { policy in
            XCTAssertEqual(policy, .cancel)
        }
        // swiftlint:disable:next force_unwrapping
        let urlRequestV3 = URLRequest(url: urlV3!)
        // swiftlint:disable:next force_unwrapping
        let urlDataV3: URLInfo = .init(urlV3!)!
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlDataV3))
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV3!, jsSubject)
        webPageState = try awaitPublisherValue(vm.webPageStatePublisher)
        XCTAssertEqual(webPageState, .load(urlRequestV3))
        XCTAssertEqual(vm.state, .viewing(settings, urlDataV3))
        
        vm.goBack()
        let msg1 = "Have to finish loading after back navigation"
        XCTAssertNotEqual(vm.state, .viewing(settings, urlInfoV1), msg1)
        XCTAssertEqual(vm.state, .waitingForNavigation(settings, urlDataV3))
        
        // swiftlint:disable:next force_unwrapping
        let navActionV11 = MockedNavAction(urlV1!, .backForward)
        vm.decidePolicy(navActionV11) { policy in
            XCTAssertEqual(policy, .allow)
        }
        
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV1), "New url is expected")
        
        // User decides to go forward
        
        vm.goForward()
        let msg2 = "Have to finish loading after forward navigation"
        XCTAssertNotEqual(vm.state, .viewing(settings, urlDataV3), msg2)
        XCTAssertEqual(vm.state, .waitingForNavigation(settings, urlInfoV1))
        
        // swiftlint:disable:next force_unwrapping
        let navActionV31 = MockedNavAction(urlV3!, .backForward)
        vm.decidePolicy(navActionV31) { policy in
            XCTAssertEqual(policy, .allow)
        }
        
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV3!, jsSubject)
        XCTAssertEqual(vm.state, .viewing(settings, urlDataV3), "New url is expected")
    }
    
    func testResetWithError() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, webViewContext)
        // no call to `load` which is expected before `reset`
        // it only can work if it is a `.viewing` state
        // which could happen only after loading initial site
        vm.reset(opennetSite)
        
        let webPageState = try awaitPublisherValue(vm.webPageStatePublisher)
        XCTAssertEqual(webPageState, .reattachViewObservers)
        XCTAssertEqual(vm.state, .initialized(exampleSite))
    }
    
    func testReset() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, webViewContext)
        vm.load()
        
        // This is a bad path case, user has to call `finishLoading`
        // to complete the load request and have a final state which is `.viewing`
        
        // swiftlint:disable:next force_unwrapping
        let urlInfoV1: URLInfo = .init(urlV1!)!
        var webPageState = try awaitPublisherValue(vm.webPageStatePublisher)
        XCTAssertEqual(webPageState, .load(urlInfoV1.urlRequest))
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlInfoV1))
        
        // swiftlint:disable:next force_unwrapping
        let navActionV1 = MockedNavAction(urlV1!, .other)
        vm.decidePolicy(navActionV1) { policy in
            XCTAssertEqual(policy, .allow)
        }
        
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        webPageState = try awaitPublisherValue(vm.webPageStatePublisher)
        XCTAssertEqual(webPageState, .load(urlInfoV1.urlRequest))
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV1))
        
        // Now it should be a valid state for reset
        vm.reset(opennetSite)
        
        // swiftlint:disable:next force_unwrapping
        let urlInfoV2: URLInfo = .init(opennetUrlV1!)!
        webPageState = try awaitPublisherValue(vm.webPageStatePublisher)
        XCTAssertEqual(webPageState, .load(urlInfoV2.urlRequest))
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlInfoV2))
        
        // swiftlint:disable:next force_unwrapping
        let navActionV2 = MockedNavAction(opennetUrlV1!, .other)
        vm.decidePolicy(navActionV2) { policy in
            XCTAssertEqual(policy, .allow)
        }
        
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(opennetUrlV1!, jsSubject)
        webPageState = try awaitPublisherValue(vm.webPageStatePublisher)
        XCTAssertEqual(webPageState, .load(urlInfoV2.urlRequest))
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV2))
    }
}
