## 1. Write use case API

- [ ] 1.1 Add `WriteTabsUseCase` protocol + `WriteTabsUseCaseImpl` in CottonUseCases with `add` and `close` operations that take `TabSelectionStrategy` + `TabsDataServiceProtocol`
- [ ] 1.2 Implement add path: call data service add with explicit `select` from `makeTabActiveAfterAdding`; ensure selected tab id matches when strategy requires activation
- [ ] 1.3 Implement close path: remove tab via data service; build `IndexSelectionContext` from snapshot; apply `autoSelectedIndexAfterTabRemove` then select when needed; handle last-tab → default tab + select
- [ ] 1.4 Add a lightweight/snapshot `IndexSelectionContext` helper (not `TabsDataService`) for strategy calls

## 2. Slim TabsDataService

- [ ] 2.1 Remove `TabSelectionStrategy` from `TabsDataService` and `DataServiceFactory.createTabsService`
- [ ] 2.2 Update add command/handler to accept explicit select (no strategy); keep notification behavior when select is true
- [ ] 2.3 Update close/remove handler to stop calling selection strategy; return/publish removal without computing next selection (selection applied via existing select command or use-case follow-up)
- [ ] 2.4 Stop conforming `TabsDataService` to `IndexSelectionContext` if unused elsewhere; keep `IndexSelectionContext` protocol available for the use-case helper

## 3. DI and call-site wiring

- [ ] 3.1 Register `WriteTabsUseCase` in `UseCaseRegistry` with `NearbySelectionStrategy` (or injected strategy)
- [ ] 3.2 Update `ServiceRegistry` / factory call sites that passed strategy into `createTabsService`
- [ ] 3.3 Point `AddTabUseCase` / `CloseTabUseCase` at `WriteTabsUseCase` (delegating façades) **or** migrate VM/factories (`ModuleVMFactory`, `ViewModelFactory`, `TabsPreviewsViewModel`, etc.) to `WriteTabsUseCase` and remove the #92 `#warning` from `CloseTabUseCase`
- [ ] 3.4 Align `writeTabUseCase` naming/types where they currently alias `CloseTabUseCase`

## 4. Tests and verification

- [ ] 4.1 Add Swift Testing coverage for write use case: add-with-select, add-without-select, close selected, close non-selected, close last tab
- [ ] 4.2 Adjust or remove TabsDataService tests that assumed strategy lived in the actor
- [ ] 4.3 Manually smoke-test add tab, close selected/non-selected, and close last tab in the app
