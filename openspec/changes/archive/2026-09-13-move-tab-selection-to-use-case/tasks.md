## 1. Enrich existing use cases

- [x] 1.1 Inject `TabSelectionStrategy` into `AddTabUseCaseImpl`; drive add with explicit `addTab(..., select:)` from `makeTabActiveAfterAdding` (do **not** depend on `SelectTabUseCase` — select-on-add stays on the add command)
- [x] 1.2 Inject `TabSelectionStrategy` into `CloseTabUseCaseImpl`; after remove, compute next selection via `autoSelectedIndexAfterTabRemove` and **apply it through `SelectTabUseCase`** (Close → Select is required for post-close reselect)
- [x] 1.3 Implement last-tab recovery in `CloseTabUseCase` (default-content tab + select) without relying on strategy inside `TabsDataService`
- [x] 1.4 Add a snapshot/value `IndexSelectionContext` helper for close-path strategy calls (not `TabsDataService`)
- [x] 1.5 Remove the issue #92 `#warning` from `CloseTabUseCase`
- [x] 1.6 Confirm `ReplaceSelectedTabUseCase` stays a thin proxy **in this change**; thickening (move replace-content domain logic out of `TabsDataService`) is an approved follow-up per design Decision 7 — not implemented here
- [x] 1.7 Switch last-tab recovery to use-case composition: `CloseTabUseCase` → `AddTabUseCase` (Add’s select-on-add policy selects the new default tab). Keep `CloseTabUseCase` → `SelectTabUseCase` for non-last-tab reselect. Keep graph acyclic (`Add` must not depend on `Close`)

## 2. Slim TabsDataService

- [x] 2.1 Remove `TabSelectionStrategy` from `TabsDataService` and `DataServiceFactory.createTabsService`
- [x] 2.2 Update add command/handler to accept explicit select (no strategy); keep notification behavior when select is true
- [x] 2.3 Update close/remove handler to stop calling selection strategy; publish removal without computing next selection
- [x] 2.4 Stop conforming `TabsDataService` to `IndexSelectionContext` if unused elsewhere; keep the protocol for the use-case helper

## 3. DI wiring

- [x] 3.1 Update `UseCaseRegistry` so `AddTabUseCase` / `CloseTabUseCase` receive `NearbySelectionStrategy`; **require** wiring `SelectTabUseCase` into `CloseTabUseCaseImpl`
- [x] 3.2 Update `ServiceRegistry` / factory call sites that passed strategy into `createTabsService`
- [x] 3.3 Optionally rename misleading `writeTabUseCase` parameters that are typed as `CloseTabUseCase` (no new aggregate type)
- [x] 3.4 Wire `AddTabUseCase` into `CloseTabUseCaseImpl` in `UseCaseRegistry` for last-tab recovery (Close → Add only; Select already wired)

## 4. Tests and verification

- [x] 4.1 Add Swift Testing for `AddTabUseCase`: add-with-select, add-without-select
- [x] 4.2 Add Swift Testing for `CloseTabUseCase`: close selected, close non-selected, close last tab
- [x] 4.3 Adjust or remove TabsDataService tests that assumed strategy lived in the actor
- [ ] 4.4 Manually smoke-test add tab, close selected/non-selected, and close last tab in the app
- [x] 4.5 Assert close last-tab recovery goes through `AddTabUseCase`; assert post-close reselect goes through `SelectTabUseCase`
