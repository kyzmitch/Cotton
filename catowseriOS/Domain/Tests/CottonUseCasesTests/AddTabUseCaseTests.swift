//
//  AddTabUseCaseTests.swift
//  CottonUseCasesTests
//

import CoreBrowser
import CottonUseCases
import Testing

struct AddTabUseCaseTests {
    @Test func addTabSelectsWhenStrategyRequiresActivation() async throws {
        let existing = CoreBrowser.Tab.blank
        let service = FakeTabsDataService(tabs: [existing], selectedTabId: existing.id)
        let strategy = FakeTabSelectionStrategy(makeTabActiveAfterAdding: true)
        let useCase = AddTabUseCaseImpl(service, strategy)
        let newTab = CoreBrowser.Tab(contentType: .blank)

        try await useCase.execute(input: newTab)

        let tabs = await service.currentTabs()
        let selectedId = await service.currentSelectedTabId()
        #expect(tabs.count == 2)
        #expect(tabs.contains(where: { $0.id == newTab.id }))
        #expect(selectedId == newTab.id)
    }

    @Test func addTabKeepsSelectionWhenStrategyDisallowsActivation() async throws {
        let existing = CoreBrowser.Tab.blank
        let service = FakeTabsDataService(tabs: [existing], selectedTabId: existing.id)
        let strategy = FakeTabSelectionStrategy(makeTabActiveAfterAdding: false)
        let useCase = AddTabUseCaseImpl(service, strategy)
        let newTab = CoreBrowser.Tab(contentType: .blank)

        try await useCase.execute(input: newTab)

        let tabs = await service.currentTabs()
        let selectedId = await service.currentSelectedTabId()
        #expect(tabs.count == 2)
        #expect(selectedId == existing.id)
    }
}
