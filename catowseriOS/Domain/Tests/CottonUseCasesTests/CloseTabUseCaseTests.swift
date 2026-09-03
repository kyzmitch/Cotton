//
//  CloseTabUseCaseTests.swift
//  CottonUseCasesTests
//

import CoreBrowser
import CottonTabs
import CottonUseCases
import Testing

struct CloseTabUseCaseTests {
    @Test func closeSelectedTabWithNeighborsSelectsStrategyIndex() async throws {
        let tabA = CoreBrowser.Tab(contentType: .blank)
        let tabB = CoreBrowser.Tab(contentType: .blank)
        let tabC = CoreBrowser.Tab(contentType: .blank)
        let service = FakeTabsDataService(
            tabs: [tabA, tabB, tabC],
            selectedTabId: tabC.id
        )
        let strategy = FakeTabSelectionStrategy(makeTabActiveAfterAdding: true)
        let selectUseCase = SelectTabUseCaseImpl(service)
        let addUseCase = AddTabUseCaseImpl(service, strategy)
        let useCase = CloseTabUseCaseImpl(
            service,
            strategy,
            selectUseCase,
            addUseCase,
            FakeTabsStates()
        )

        let newSelectedId = try await useCase.execute(input: tabC)

        let tabs = await service.currentTabs()
        let selectedId = await service.currentSelectedTabId()
        #expect(tabs.map(\.id) == [tabA.id, tabB.id])
        #expect(newSelectedId == tabB.id)
        #expect(selectedId == tabB.id)
    }

    @Test func closeNonSelectedTabLeavesSelectionUnchanged() async throws {
        let tabA = CoreBrowser.Tab(contentType: .blank)
        let tabB = CoreBrowser.Tab(contentType: .blank)
        let tabC = CoreBrowser.Tab(contentType: .blank)
        let service = FakeTabsDataService(
            tabs: [tabA, tabB, tabC],
            selectedTabId: tabB.id
        )
        let strategy = FakeTabSelectionStrategy(makeTabActiveAfterAdding: true)
        let selectUseCase = SelectTabUseCaseImpl(service)
        let addUseCase = AddTabUseCaseImpl(service, strategy)
        let useCase = CloseTabUseCaseImpl(
            service,
            strategy,
            selectUseCase,
            addUseCase,
            FakeTabsStates()
        )

        let newSelectedId = try await useCase.execute(input: tabC)

        let tabs = await service.currentTabs()
        let selectedId = await service.currentSelectedTabId()
        #expect(tabs.map(\.id) == [tabA.id, tabB.id])
        #expect(newSelectedId == nil)
        #expect(selectedId == tabB.id)
    }

    @Test func closeSelectedNonLastTabSelectsTabAtSameIndex() async throws {
        let tabA = CoreBrowser.Tab(contentType: .blank)
        let tabB = CoreBrowser.Tab(contentType: .blank)
        let tabC = CoreBrowser.Tab(contentType: .blank)
        let service = FakeTabsDataService(
            tabs: [tabA, tabB, tabC],
            selectedTabId: tabB.id
        )
        let strategy = FakeTabSelectionStrategy(makeTabActiveAfterAdding: true)
        let selectUseCase = SelectTabUseCaseImpl(service)
        let addUseCase = AddTabUseCaseImpl(service, strategy)
        let useCase = CloseTabUseCaseImpl(
            service,
            strategy,
            selectUseCase,
            addUseCase,
            FakeTabsStates()
        )

        let newSelectedId = try await useCase.execute(input: tabB)

        let tabs = await service.currentTabs()
        let selectedId = await service.currentSelectedTabId()
        #expect(tabs.map(\.id) == [tabA.id, tabC.id])
        #expect(newSelectedId == tabC.id)
        #expect(selectedId == tabC.id)
    }

    @Test func closeLastTabAddsDefaultSelectedTab() async throws {
        let only = CoreBrowser.Tab(contentType: .blank)
        let service = FakeTabsDataService(tabs: [only], selectedTabId: only.id)
        let strategy = FakeTabSelectionStrategy(makeTabActiveAfterAdding: true)
        let selectUseCase = SelectTabUseCaseImpl(service)
        let addUseCase = AddTabUseCaseImpl(service, strategy)
        let useCase = CloseTabUseCaseImpl(
            service,
            strategy,
            selectUseCase,
            addUseCase,
            FakeTabsStates()
        )

        let newSelectedId = try await useCase.execute(input: only)

        let tabs = await service.currentTabs()
        let selectedId = await service.currentSelectedTabId()
        #expect(tabs.count == 1)
        #expect(tabs.first?.id != only.id)
        #expect(newSelectedId == tabs.first?.id)
        #expect(selectedId == tabs.first?.id)
    }

    @Test func closeLastTabRecoveryUsesAddTabUseCase() async throws {
        let only = CoreBrowser.Tab(contentType: .blank)
        let service = FakeTabsDataService(tabs: [only], selectedTabId: only.id)
        let strategy = FakeTabSelectionStrategy(makeTabActiveAfterAdding: true)
        let realAddUseCase = AddTabUseCaseImpl(service, strategy)
        let addUseCase = FakeAddTabUseCase(real: realAddUseCase)
        let selectUseCase = FakeSelectTabUseCase()
        let useCase = CloseTabUseCaseImpl(
            service,
            strategy,
            selectUseCase,
            addUseCase,
            FakeTabsStates()
        )

        _ = try await useCase.execute(input: only)

        #expect(addUseCase.executeCalls.count == 1)
        #expect(selectUseCase.executeCalls.isEmpty)
    }

    @Test func postCloseReselectUsesSelectTabUseCase() async throws {
        let tabA = CoreBrowser.Tab(contentType: .blank)
        let tabB = CoreBrowser.Tab(contentType: .blank)
        let tabC = CoreBrowser.Tab(contentType: .blank)
        let service = FakeTabsDataService(
            tabs: [tabA, tabB, tabC],
            selectedTabId: tabC.id
        )
        let strategy = FakeTabSelectionStrategy(makeTabActiveAfterAdding: true)
        let realSelectUseCase = SelectTabUseCaseImpl(service)
        let selectUseCase = FakeSelectTabUseCase(real: realSelectUseCase)
        let addUseCase = FakeAddTabUseCase()
        let useCase = CloseTabUseCaseImpl(
            service,
            strategy,
            selectUseCase,
            addUseCase,
            FakeTabsStates()
        )

        _ = try await useCase.execute(input: tabC)

        #expect(selectUseCase.executeCalls.count == 1)
        #expect(selectUseCase.executeCalls.first?.id == tabB.id)
        #expect(addUseCase.executeCalls.isEmpty)
    }
}
