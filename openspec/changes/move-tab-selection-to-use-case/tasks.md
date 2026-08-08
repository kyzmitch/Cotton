## 1. Enrich existing use cases

- [ ] 1.1 Inject `TabSelectionStrategy` into `AddTabUseCaseImpl`; drive add with explicit select from `makeTabActiveAfterAdding` (compose `SelectTabUseCase` if needed)
- [ ] 1.2 Inject `TabSelectionStrategy` into `CloseTabUseCaseImpl`; after remove, compute next selection via `autoSelectedIndexAfterTabRemove` and apply it (compose `SelectTabUseCase` when needed)
- [ ] 1.3 Implement last-tab recovery in `CloseTabUseCase` (default-content tab + select) without relying on strategy inside `TabsDataService`
- [ ] 1.4 Add a snapshot/value `IndexSelectionContext` helper for close-path strategy calls (not `TabsDataService`)
- [ ] 1.5 Remove the issue #92 `#warning` from `CloseTabUseCase`
- [ ] 1.6 Leave `ReplaceSelectedTabUseCase` as a thin proxy in this change unless a shared helper is extracted for all write use cases

## 2. Slim TabsDataService

- [ ] 2.1 Remove `TabSelectionStrategy` from `TabsDataService` and `DataServiceFactory.createTabsService`
- [ ] 2.2 Update add command/handler to accept explicit select (no strategy); keep notification behavior when select is true
- [ ] 2.3 Update close/remove handler to stop calling selection strategy; publish removal without computing next selection
- [ ] 2.4 Stop conforming `TabsDataService` to `IndexSelectionContext` if unused elsewhere; keep the protocol for the use-case helper

## 3. DI wiring

- [ ] 3.1 Update `UseCaseRegistry` so `AddTabUseCase` / `CloseTabUseCase` receive `NearbySelectionStrategy` (or injected strategy); wire `SelectTabUseCase` into close/add if composed
- [ ] 3.2 Update `ServiceRegistry` / factory call sites that passed strategy into `createTabsService`
- [ ] 3.3 Optionally rename misleading `writeTabUseCase` parameters that are typed as `CloseTabUseCase` (no new aggregate type)

## 4. Tests and verification

- [ ] 4.1 Add Swift Testing for `AddTabUseCase`: add-with-select, add-without-select
- [ ] 4.2 Add Swift Testing for `CloseTabUseCase`: close selected, close non-selected, close last tab
- [ ] 4.3 Adjust or remove TabsDataService tests that assumed strategy lived in the actor
- [ ] 4.4 Manually smoke-test add tab, close selected/non-selected, and close last tab in the app
