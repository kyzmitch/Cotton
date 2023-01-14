//
//  WebViewVMCombineTests.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 10/3/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import XCTest
@testable import CoreCatowser
import HttpKit
import CoreHttpKit
import WebKit

final class WebViewVMCombineTests: WebViewVMFixture {
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
    }
    
    func testLoadWithError() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, webViewContext)
        vm.load()
        
        // This is a bad path case, user has to call `finishLoading`
        // to complete the load request and have a final state which is `.viewing`
        
        // swiftlint:disable:next force_unwrapping
        let urlInfoV1: URLInfo = .init(urlV1!)!
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlInfoV1.urlRequest))
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlInfoV1))
        vm.load()
        
        // Even if reattach was called 2nd time in this case
        // on view level it won't do anything because internal `webViewObserversAdded`
        // will protect from the issues
        
        XCTAssertEqual(vm.combineWebPageState.value, .reattachViewObservers)
        let errMsg1 = "State should stay the same when wrong action is getting called"
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlInfoV1), errMsg1)
        // swiftlint:disable:next force_unwrapping
        let navActionV1 = MockedNavAction(urlV1!, .other)
        vm.decidePolicy(navActionV1) { policy in
            XCTAssertEqual(policy, .allow)
        }
        
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        XCTAssertEqual(vm.combineWebPageState.value, .reattachViewObservers)
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV1))
    }
    
    func testLinkActivation() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, webViewContext)
        vm.load()
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
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlDataV3.urlRequest))
        XCTAssertEqual(vm.state, .viewing(settings, urlDataV3))
    }
    
    func testReload() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, webViewContext)
        vm.load()
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
        
        vm.reload()
        XCTAssertEqual(vm.state, .waitingForNavigation(settings, urlInfoV1))
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV1))
    }
    
    func testGoBack() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, webViewContext)
        vm.load()
        // swiftlint:disable:next force_unwrapping
        let urlRequestV1 = URLRequest(url: urlV1!)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV1))
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
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV1))
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
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV3))
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
    
    func testGoForward() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, webViewContext)
        vm.load()
        // swiftlint:disable:next force_unwrapping
        let urlRequestV1 = URLRequest(url: urlV1!)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV1))
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
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV1))
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
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV3))
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
        
        XCTAssertEqual(vm.combineWebPageState.value, .reattachViewObservers)
        XCTAssertEqual(vm.state, .initialized(exampleSite))
    }
    
    func testReset() throws {
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
        
        // Now it should be a valid state for reset
        vm.reset(opennetSite)
        
        // swiftlint:disable:next force_unwrapping
        let urlInfoV2: URLInfo = .init(opennetUrlV1!)!
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlInfoV2.urlRequest))
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlInfoV2))
        
        // swiftlint:disable:next force_unwrapping
        let navActionV2 = MockedNavAction(opennetUrlV1!, .other)
        vm.decidePolicy(navActionV2) { policy in
            XCTAssertEqual(policy, .allow)
        }
        
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(opennetUrlV1!, jsSubject)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlInfoV2.urlRequest))
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV2))
    }
    
    func testSystemAppRedirect() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, webViewContext)
        vm.load()
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
        
        // User taps on a link in web view which is actually a Deep Link for the app

        let navActionV4 = MockedNavAction(urlV4, .linkActivated)
        vm.decidePolicy(navActionV4) { policy in
            XCTAssertEqual(policy, .cancel)
        }
        XCTAssertEqual(vm.combineWebPageState.value, .openApp(urlV4))
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV1))
        // `finishLoading` won't be called if there was an App redirect
    }
    
    func testNativeAppRedirect() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, webViewContext)
        vm.load()
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
        
        // User taps on a link in web view which is actually a Deep Link for the app

        let navActionV5 = MockedNavAction(urlV5, .linkActivated)
        vm.decidePolicy(navActionV5) { policy in
            XCTAssertEqual(policy, .cancel)
        }
        // swiftlint:disable:next force_unwrapping
        let urlDataV5: URLInfo = URLInfo(urlV5)!
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlDataV5))
        vm.finishLoading(urlV5, jsSubject)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlDataV5.urlRequest))
        XCTAssertEqual(vm.state, .viewing(settings, urlDataV5))
    }
    
    func testNativeAppRedirectCancel() throws {
        webViewContext = .init(doh: false,
                               js: false,
                               nativeAppRedirect: false,
                               asyncApiType: .combine,
                               appName: "instagram.com")
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, webViewContext)
        vm.load()
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
        
        // User taps on a link in web view which is actually a Deep Link for the app

        let navActionV5 = MockedNavAction(urlV5, .linkActivated)
        vm.decidePolicy(navActionV5) { policy in
            let ignoreAppRawValue = WKNavigationActionPolicy.allow.rawValue + 2
            // swiftlint:disable:next force_unwrapping
            let expectedPolicy = WKNavigationActionPolicy(rawValue: ignoreAppRawValue)!
            XCTAssertEqual(policy, expectedPolicy)
        }
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlInfoV1.urlRequest))
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV1))
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlInfoV1.urlRequest))
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV1))
    }
    
    func testResetWithNotFinishedNavigation() throws {
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
        
        // Now perform a navigation which, let's say, won't finish in time
        vm.goBack()
        XCTAssertEqual(vm.state, .waitingForNavigation(settings, urlInfoV1))
        
        // It still should be possible to reset VM to a new site
        // even when navigation of previous web view didn't finish in time
        // and view state is not `viewing` but `waitingForNavigation`
        vm.reset(opennetSite)
        
        // swiftlint:disable:next force_unwrapping
        let urlInfoV2: URLInfo = .init(opennetUrlV1!)!
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlInfoV2.urlRequest))
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlInfoV2))
        
        // swiftlint:disable:next force_unwrapping
        let navActionV2 = MockedNavAction(opennetUrlV1!, .other)
        vm.decidePolicy(navActionV2) { policy in
            XCTAssertEqual(policy, .allow)
        }
        
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(opennetUrlV1!, jsSubject)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlInfoV2.urlRequest))
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV2))
    }
    
    func testReloadWithNotFinishedNavigation() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, webViewContext)
        vm.load()
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
        
        vm.reload()
        XCTAssertEqual(vm.state, .waitingForNavigation(settings, urlInfoV1))
        
        // Previous navigation wasn't finished but it is possible to start
        // new navigation, because of WKWebView behaviour
        // maybe if navigation buttons weren't enabled for interaction
        // then it won't be a case
        
        vm.reload()
        XCTAssertEqual(vm.state, .waitingForNavigation(settings, urlInfoV1))
        
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV1))
    }
}
