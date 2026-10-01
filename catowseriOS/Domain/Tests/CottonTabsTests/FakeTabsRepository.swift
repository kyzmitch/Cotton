//
//  FakeTabsRepository.swift
//  CottonTabsTests
//

import CoreBrowser
import CottonTabs
import Foundation

actor FakeTabsRepository: @preconcurrency TabsRepository {
    private var storedTabs: [CoreBrowser.Tab]
    private var storedSelectedId: CoreBrowser.Tab.ID
    private var fetchAllError: Error?
    private var fetchSelectedError: Error?
    private var fetchAllGate: AsyncGate?
    private var addGate: AsyncGate?
    private var removeGate: AsyncGate?

    private(set) var fetchAllCount = 0
    private(set) var fetchSelectedCount = 0
    private(set) var addCount = 0
    private(set) var removeCount = 0

    init(
        tabs: [CoreBrowser.Tab] = [],
        selectedTabId: CoreBrowser.Tab.ID? = nil
    ) {
        self.storedTabs = tabs
        self.storedSelectedId = selectedTabId ?? tabs.first?.id ?? Tab.ID()
    }

    func setTabs(_ tabs: [CoreBrowser.Tab], selectedTabId: CoreBrowser.Tab.ID? = nil) {
        storedTabs = tabs
        if let selectedTabId {
            storedSelectedId = selectedTabId
        } else if let first = tabs.first {
            storedSelectedId = first.id
        }
    }

    func setFetchAllError(_ error: Error?) {
        fetchAllError = error
    }

    func setFetchSelectedError(_ error: Error?) {
        fetchSelectedError = error
    }

    func setFetchAllGate(_ gate: AsyncGate?) {
        fetchAllGate = gate
    }

    func setAddGate(_ gate: AsyncGate?) {
        addGate = gate
    }

    func setRemoveGate(_ gate: AsyncGate?) {
        removeGate = gate
    }

    func fetchSelectedTabId() async throws -> CoreBrowser.Tab.ID {
        fetchSelectedCount += 1
        if let fetchSelectedError {
            throw fetchSelectedError
        }
        return storedSelectedId
    }

    func select(tab: CoreBrowser.Tab) async throws -> CoreBrowser.Tab.ID {
        storedSelectedId = tab.id
        return tab.id
    }

    func fetchAllTabs() async throws -> [CoreBrowser.Tab] {
        fetchAllCount += 1
        if let fetchAllError {
            throw fetchAllError
        }
        if let fetchAllGate {
            await fetchAllGate.wait()
        }
        return storedTabs
    }

    func add(_ tab: CoreBrowser.Tab, select: Bool) async throws -> CoreBrowser.Tab {
        addCount += 1
        if let addGate {
            await addGate.wait()
        }
        storedTabs.append(tab)
        if select {
            storedSelectedId = tab.id
        }
        return tab
    }

    func update(tab: CoreBrowser.Tab) throws -> CoreBrowser.Tab {
        if let index = storedTabs.firstIndex(where: { $0.id == tab.id }) {
            storedTabs[index] = tab
        }
        return tab
    }

    func remove(tabs: [CoreBrowser.Tab]) async throws -> [CoreBrowser.Tab] {
        removeCount += 1
        if let removeGate {
            await removeGate.wait()
        }
        storedTabs.removeAll { candidate in
            tabs.contains(candidate)
        }
        return tabs
    }
}
