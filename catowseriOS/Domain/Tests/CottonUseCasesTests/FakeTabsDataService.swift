//
//  FakeTabsDataService.swift
//  CottonUseCasesTests
//

import CoreBrowser
import CottonTabs
import Foundation

/// In-memory tabs data service for use-case unit tests.
actor FakeTabsDataService: TabsDataServiceProtocol {
    var serviceData: TabsServiceData
    private var tabs: [CoreBrowser.Tab]
    private var selectedTabId: CoreBrowser.Tab.ID

    init(tabs: [CoreBrowser.Tab], selectedTabId: CoreBrowser.Tab.ID) {
        self.tabs = tabs
        self.selectedTabId = selectedTabId
        var data = TabsServiceData()
        data.allTabs = .finished(output: .success(tabs))
        data.selectedTabId = .finished(output: .success(selectedTabId))
        data.tabsCount = .finished(output: .success(tabs.count))
        self.serviceData = data
    }

    func sendCommand(
        _ command: TabsServiceCommand,
        _ input: TabsServiceData?
    ) async -> TabsServiceData {
        switch command {
        case .getTabsCount:
            serviceData.tabsCount = .finished(output: .success(tabs.count))
        case .getSelectedTabId:
            serviceData.selectedTabId = .finished(output: .success(selectedTabId))
        case .getAllTabs:
            serviceData.allTabs = .finished(output: .success(tabs))
        case .addTab(let tab, let select):
            tabs.append(tab)
            if select {
                selectedTabId = tab.id
                serviceData.selectedTabId = .finished(output: .success(selectedTabId))
            }
            serviceData.allTabs = .finished(output: .success(tabs))
            serviceData.tabsCount = .finished(output: .success(tabs.count))
            serviceData.tabAdded = .finished(output: .success(tabs.count - 1))
        case .closeTab(let tab):
            tabs.removeAll { $0.id == tab.id }
            serviceData.allTabs = .finished(output: .success(tabs))
            serviceData.tabsCount = .finished(output: .success(tabs.count))
            serviceData.tabClosed = .finished(output: .success(nil))
        case .selectTab(let tab):
            selectedTabId = tab.id
            serviceData.selectedTabId = .finished(output: .success(selectedTabId))
            serviceData.tabSelected = .finished(output: .success(()))
        case .closeTabWithId, .closeAll, .replaceContent, .updateSelectedTabPreview:
            break
        }
        return serviceData
    }

    func attach(_ observer: TabsObserver, notify: Bool) async {}

    func currentSelectedTabId() -> CoreBrowser.Tab.ID {
        selectedTabId
    }

    func currentTabs() -> [CoreBrowser.Tab] {
        tabs
    }
}
