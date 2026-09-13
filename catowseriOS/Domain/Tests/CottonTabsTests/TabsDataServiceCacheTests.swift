//
//  TabsDataServiceCacheTests.swift
//  CottonTabsTests
//

import CoreBrowser
import Foundation
import GenericServiceKit
import Testing
@testable import CottonTabs

struct TabsDataServiceCacheTests {
    @Test func initialAllTabsLoadIsSingleFlightAndNotifiesObservers() async throws {
        let existing = CoreBrowser.Tab(contentType: .blank)
        let repository = FakeTabsRepository(tabs: [existing], selectedTabId: existing.id)
        let service = await TabsDataService(repository, FakeTabsStates(), nil)
        let observer = await MainActor.run { RecordingTabsObserver() }
        await service.attach(observer, notify: true)

        async let first = service.sendCommand(.getAllTabs, nil)
        async let second = service.sendCommand(.getAllTabs, nil)
        let firstData = await first
        let secondData = await second

        #expect(await repository.fetchAllCount == 1)
        let firstTabs = try finishedTabs(firstData.allTabs)
        let secondTabs = try finishedTabs(secondData.allTabs)
        #expect(firstTabs.map(\.id) == [existing.id])
        #expect(secondTabs.map(\.id) == [existing.id])
        #expect(await observer.initializedTabs.map(\.id) == [existing.id])
    }

    @Test func failedInitRetryCoalescesConcurrentGetAllTabs() async throws {
        let existing = CoreBrowser.Tab(contentType: .blank)
        let repository = FakeTabsRepository(tabs: [existing], selectedTabId: existing.id)
        await repository.setFetchAllError(NSError(domain: "test", code: 1))
        let service = await TabsDataService(repository, FakeTabsStates(), nil)
        #expect(await repository.fetchAllCount == 1)

        await repository.setFetchAllError(nil)
        let gate = AsyncGate()
        await repository.setFetchAllGate(gate)

        async let first = service.sendCommand(.getAllTabs, nil)
        await gate.waitForEntry()
        async let second = service.sendCommand(.getAllTabs, nil)
        await gate.open()
        let firstData = await first
        let secondData = await second

        #expect(await repository.fetchAllCount == 2)
        #expect(try finishedTabs(firstData.allTabs).map(\.id) == [existing.id])
        #expect(try finishedTabs(secondData.allTabs).map(\.id) == [existing.id])
    }

    @Test func selectedTabIdPreSeedFallsBackWhenRepositoryFails() async throws {
        let existing = CoreBrowser.Tab(contentType: .blank)
        let defaultId = Tab.ID()
        let repository = FakeTabsRepository(tabs: [existing], selectedTabId: existing.id)
        await repository.setFetchSelectedError(NSError(domain: "test", code: 2))
        let positioning = FakeTabsStates(defaultSelectedTabId: defaultId)
        let service = await TabsDataService(repository, positioning, nil)

        let data = await service.sendCommand(.getSelectedTabId, nil)
        #expect(try finishedTabs(data.allTabs).map(\.id) == [existing.id])
        #expect(try finishedIdentifier(data.selectedTabId) == defaultId)
        #expect(await repository.fetchSelectedCount == 1)
        guard case .finished(let output) = data.selectedTabId else {
            Issue.record("selectedTabId should be finished after fallback")
            return
        }
        if case .failure = output {
            Issue.record("selectedTabId must not be .failure after a repository miss")
        }
    }

    @Test func addTabWaitsForInProgressAllTabsThenAdds() async throws {
        let existing = CoreBrowser.Tab(contentType: .blank)
        let repository = FakeTabsRepository(tabs: [existing], selectedTabId: existing.id)
        await repository.setFetchAllError(NSError(domain: "test", code: 3))
        let service = await TabsDataService(repository, FakeTabsStates(), nil)

        await repository.setFetchAllError(nil)
        let gate = AsyncGate()
        await repository.setFetchAllGate(gate)
        let newTab = CoreBrowser.Tab(contentType: .blank)

        async let load = service.sendCommand(.getAllTabs, nil)
        await gate.waitForEntry()
        async let add = service.sendCommand(.addTab(newTab, select: true), nil)
        await gate.open()
        let addData = await add
        _ = await load

        #expect(try finishedIndex(addData.tabAdded) == 1)
        let tabs = try finishedTabs(addData.allTabs)
        #expect(tabs.map(\.id) == [existing.id, newTab.id])
    }

    @Test func overlappingAddTabCommandsSerializeThroughSharedLock() async throws {
        let existing = CoreBrowser.Tab(contentType: .blank)
        let repository = FakeTabsRepository(tabs: [existing], selectedTabId: existing.id)
        let service = await TabsDataService(repository, FakeTabsStates(), nil)
        let gate = AsyncGate()
        await repository.setAddGate(gate)
        let firstTab = CoreBrowser.Tab(contentType: .blank)
        let secondTab = CoreBrowser.Tab(contentType: .blank)

        async let first = service.sendCommand(.addTab(firstTab, select: true), nil)
        await gate.waitForEntry()
        async let second = service.sendCommand(.addTab(secondTab, select: true), nil)
        await gate.open()
        let firstData = await first
        let secondData = await second

        #expect(await repository.addCount == 2)
        let firstIndex = try finishedIndex(firstData.tabAdded)
        let secondIndex = try finishedIndex(secondData.tabAdded)
        #expect(firstIndex == 1)
        #expect(secondIndex == 2)
        #expect(secondIndex != firstIndex)
        let tabs = try finishedTabs(secondData.allTabs)
        #expect(Set(tabs.map(\.id)) == Set([existing.id, firstTab.id, secondTab.id]))
    }

    @Test func closeTabWaitsForInFlightAddThenMutatesPostAddCache() async throws {
        let existing = CoreBrowser.Tab(contentType: .blank)
        let repository = FakeTabsRepository(tabs: [existing], selectedTabId: existing.id)
        let service = await TabsDataService(repository, FakeTabsStates(), nil)
        let gate = AsyncGate()
        await repository.setAddGate(gate)
        let added = CoreBrowser.Tab(contentType: .blank)

        async let add = service.sendCommand(.addTab(added, select: true), nil)
        await gate.waitForEntry()
        async let close = service.sendCommand(.closeTab(existing), nil)
        await gate.open()
        _ = await add
        let closeData = await close

        guard case .finished(let closed) = closeData.tabClosed,
              case .success = closed else {
            Issue.record("Expected close to succeed after waiting for add")
            return
        }
        let tabs = try finishedTabs(closeData.allTabs)
        #expect(tabs.map(\.id) == [added.id])
        #expect(!tabs.contains(where: { $0.id == existing.id }))
    }
}

private func finishedTabs(_ data: AllTabsData) throws -> [CoreBrowser.Tab] {
    guard case .finished(let output) = data, case .success(let tabs) = output else {
        throw TestFailure("expected finished allTabs, got \(data)")
    }
    return tabs
}

private func finishedIdentifier(_ data: SelectedTabData) throws -> CoreBrowser.Tab.ID {
    guard case .finished(let output) = data, case .success(let identifier) = output else {
        throw TestFailure("expected finished selectedTabId, got \(data)")
    }
    return identifier
}

private func finishedIndex(_ data: AddTabData) throws -> TabIndex {
    guard case .finished(let output) = data, case .success(let index) = output else {
        throw TestFailure("expected finished tabAdded, got \(data)")
    }
    return index
}

private struct TestFailure: Error, CustomStringConvertible {
    let description: String
    init(_ description: String) {
        self.description = description
    }
}
