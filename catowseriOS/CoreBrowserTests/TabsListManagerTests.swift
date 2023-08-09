//
//  TabsListManagerTests.swift
//  CoreBrowserTests
//
//  Created by Andrei Ermoshin on 4/13/21.
//  Copyright © 2021 andreiermoshin. All rights reserved.
//

import XCTest
import CoreBrowser
import CottonBase

extension UUID {
    static let testId1: UUID = .init(uuid: (1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1))
    static let testId2: UUID = .init(uuid: (0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1))
    static let notPossibleId: UUID = .init(uuid: (0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1))
}

class TabsListManagerTests: XCTestCase {
    
    let tabsStorageMock: TabsStoragableMock = .init()
    
    let tabsStates: TabsStatesMock = .init()
    
    let selectionStrategyMock: TabSelectionStrategyMock = .init()
    
    let exampleTabId: UUID = .testId1
    let knownTabId: UUID = .testId2
    
    let settings: Site.Settings = .init(isPrivate: false,
                                        blockPopups: true,
                                        isJSEnabled: false,
                                        canLoadPlugins: false)
    
    // swiftlint:disable:next force_try
    let exampleDomainName: DomainName = try! .init(input: "www.example.com")
    // swiftlint:disable:next force_try
    let knownDomainName: DomainName = try! .init(input: "www.known.com")
    lazy var exampleURLInfo: URLInfo = .init(scheme: .https,
                                             path: "foo/bar",
                                             query: nil,
                                             domainName: exampleDomainName,
                                             ipAddress: nil)
    lazy var knownURLInfo: URLInfo = .init(scheme: .https,
                                           path: "bar/bar",
                                           query: nil,
                                           domainName: knownDomainName,
                                           ipAddress: nil)
    
    lazy var exampleSite: Site = .init(urlInfo: exampleURLInfo,
                                       settings: settings,
                                       faviconData: nil,
                                       searchSuggestion: nil,
                                       userSpecifiedTitle: nil)
    
    lazy var knownSite: Site = .init(urlInfo: knownURLInfo,
                                     settings: settings,
                                     faviconData: nil,
                                     searchSuggestion: nil,
                                     userSpecifiedTitle: nil)

    func testFailedInit() async throws {
        tabsStates.defaultSelectedTabId = .notPossibleId
        tabsStorageMock.fetchAllTabsThrowableError = TabStorageError.notFound

        let tabsMgr = await TabsListManager(tabsStorageMock, tabsStates, selectionStrategyMock)
        let tabsCount = await tabsMgr.tabsCount
        XCTAssertEqual(tabsCount, 0)
        let selectedTabId = await tabsMgr.selectedId
        XCTAssertEqual(selectedTabId, .notPossibleId)
        // Not testing `tabsMgr.collectionLastIndex` and `tabsMgr.currentlySelectedIndex`
        // because they would trigger assertion failure with currently used `MockedWithErrorTabsStorage`
        // which doesn't return any initial tabs
        let tabs = await tabsMgr.allTabs
        XCTAssertEqual(tabs, [])
    }
    
    func testInit() async throws {
        let tab1: Tab = .init(contentType: .site(exampleSite), idenifier: exampleTabId)
        let tab2: Tab = .init(contentType: .site(knownSite), idenifier: knownTabId)
        let tabsV1: [Tab] = [tab1, tab2]
        
        tabsStates.defaultSelectedTabId = .notPossibleId
        tabsStorageMock.fetchAllTabsReturnValue = tabsV1
        tabsStorageMock.fetchSelectedTabIdReturnValue = knownTabId
        let tabsMgr = await TabsListManager(tabsStorageMock, tabsStates, selectionStrategyMock)
        let tabsCount = await tabsMgr.tabsCount
        let selectedTabId = await tabsMgr.selectedId
        XCTAssertEqual(selectedTabId, knownTabId)
        XCTAssertEqual(tabsCount, tabsV1.count)
        let tabs = await tabsMgr.allTabs
        XCTAssertEqual(tabs, tabsV1)
        
        // User selects already selected
        
        tabsStorageMock.selectTabReturnValue = tab2.id
        await tabsMgr.select(tab: tab2)
        let nextSelectedTabId2 = await tabsMgr.selectedId
        XCTAssertEqual(nextSelectedTabId2, knownTabId)
        
        tabsStorageMock.selectTabReturnValue = tab1.id
        await tabsMgr.select(tab: tab1)
        let nextSelectedTabId1 = await tabsMgr.selectedId
        XCTAssertEqual(nextSelectedTabId1, exampleTabId)
    }
}
