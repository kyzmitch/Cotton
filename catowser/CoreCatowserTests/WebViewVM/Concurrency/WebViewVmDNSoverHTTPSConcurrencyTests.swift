//
//  WebViewVmDNSoverHTTPSConcurrencyTests.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 1/12/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import XCTest
@testable import CoreCatowser
import HttpKit
import CoreHttpKit
import WebKit
import Combine

final class WebViewVmDNSoverHTTPSConcurrencyTests: WebViewVMFixture {
    // to use instead `awaitPublisherValue` for this specific test
    private var publisherValueCounter = 0
    private var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        exampleIpAddress = "100.0.12.7"
        try super.setUpWithError()
        webViewContext = .init(doh: true, js: false, asyncApiType: .asyncAwait)
        publisherValueCounter = 0
        cancellables = []
    }
    
    func testLoad() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, webViewContext)
        
        // swiftlint:disable:next force_unwrapping force_try
        let resolvedUrlV1 = try! urlV1!.updatedHost(with: exampleIpAddress!)
        let urlRequestV1 = URLRequest(url: resolvedUrlV1)
        
        publisherValueCounter = 3
        let cancellable = vm.webPageStatePublisher.sink { webPageState in
            if self.publisherValueCounter == 3 {
                XCTAssertEqual(webPageState, .recreateView(false))
                self.publisherValueCounter -= 1
            } else if self.publisherValueCounter == 2 {
                XCTAssertEqual(webPageState, .reattachViewObservers)
                self.publisherValueCounter -= 1
            } else if self.publisherValueCounter == 1 {
                XCTAssertEqual(webPageState, .load(urlRequestV1))
                self.publisherValueCounter -= 1
            }
        }
        cancellables.insert(cancellable)
        vm.load()
        
        // swiftlint:disable:next force_unwrapping
        let urlInfoV1 = URLInfo(urlV1!)!
        let expectedStateV1: WebViewModelState = .resolvingDN(urlInfoV1, settings)
        XCTAssertEqual(vm.state, expectedStateV1)
        _ = XCTWaiter.wait(for: [expectation(description: "Wait for async domain name resolving")], timeout: 1.0)
        // swiftlint:disable:next force_unwrapping
        let urlInfoV11: URLInfo = urlInfoV1.withIPAddress(ipAddress: exampleIpAddress!)
        let expectedStateV11: WebViewModelState = .updatingWebView(settings, urlInfoV11)
        XCTAssertEqual(vm.state, expectedStateV11)
        
        let navActionV1 = MockedNavAction(resolvedUrlV1, .other)
        vm.decidePolicy(navActionV1) { policy in
            XCTAssertEqual(policy, .allow)
        }
        vm.finishLoading(resolvedUrlV1, jsSubject)
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV11))
    }
    
    func testNextLink() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, webViewContext)
        
        // swiftlint:disable:next force_unwrapping force_try
        let resolvedUrlV1 = try! urlV1!.updatedHost(with: exampleIpAddress!)
        let urlRequestV1 = URLRequest(url: resolvedUrlV1)
        
        publisherValueCounter = 3
        let cancellable = vm.webPageStatePublisher.sink { webPageState in
            if self.publisherValueCounter == 3 {
                XCTAssertEqual(webPageState, .recreateView(false))
                self.publisherValueCounter -= 1
            } else if self.publisherValueCounter == 2 {
                XCTAssertEqual(webPageState, .reattachViewObservers)
                self.publisherValueCounter -= 1
            } else if self.publisherValueCounter == 1 {
                XCTAssertEqual(webPageState, .load(urlRequestV1))
                self.publisherValueCounter -= 1
            }
        }
        cancellables.insert(cancellable)
        vm.load()
        
        // swiftlint:disable:next force_unwrapping
        let urlInfoV1 = URLInfo(urlV1!)!
        let expectedStateV1: WebViewModelState = .resolvingDN(urlInfoV1, settings)
        XCTAssertEqual(vm.state, expectedStateV1)
        _ = XCTWaiter.wait(for: [expectation(description: "Wait for async domain name resolving")], timeout: 1.0)
        // swiftlint:disable:next force_unwrapping
        let urlInfoV11: URLInfo = urlInfoV1.withIPAddress(ipAddress: exampleIpAddress!)
        let expectedStateV11: WebViewModelState = .updatingWebView(settings, urlInfoV11)
        XCTAssertEqual(vm.state, expectedStateV11)
        
        let navActionV1 = MockedNavAction(resolvedUrlV1, .other)
        vm.decidePolicy(navActionV1) { policy in
            XCTAssertEqual(policy, .allow)
        }
        vm.finishLoading(resolvedUrlV1, jsSubject)
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV11))
        
        // NEXT LINK PART
        // It is when site was already loaded with DoH and
        // user taps on a link from that site
        // we can expect that the link has already resolved host
        
        // swiftlint:disable:next force_unwrapping force_try
        let resolvedUrlV3 = try! urlV3!.updatedHost(with: exampleIpAddress!)
        let navActionV2 = MockedNavAction(resolvedUrlV3, .linkActivated)
        vm.decidePolicy(navActionV2) { policy in
            XCTAssertEqual(policy, .cancel)
        }
        // swiftlint:disable:next force_unwrapping
        let urlInfoV2 = urlInfoV11.withSimilar(resolvedUrlV3)!
        let expectedStateV2: WebViewModelState = .updatingWebView(settings, urlInfoV2)
        XCTAssertEqual(vm.state, expectedStateV2)
        vm.finishLoading(resolvedUrlV3, jsSubject)

        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV2))
    }
}
