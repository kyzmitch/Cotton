## Why

`TabsDataService` currently owns both tab persistence (add/remove) and selection policy (select newly added tabs, recompute selection after closing the selected tab via `TabSelectionStrategy`). That mixes infrastructure with domain orchestration and leaves `CloseTabUseCase` as a thin pass-through with an open TODO for [issue #92](https://github.com/kyzmitch/Cotton/issues/92). Moving selection decisions into the use-case layer keeps the data service focused on storage/state updates and makes selection policy testable without the full tabs actor.

## What Changes

- Extract post-mutation tab selection (after close of selected tab; after add when the new tab should become active) from `TabsDataService` into the use-case layer, e.g. a `WriteTabsUseCase` (or equivalent orchestration over existing add/close use cases).
- Have the use case own `TabSelectionStrategy` decisions: whether to select a newly added tab, and which tab becomes selected after removal.
- Slim `TabsDataService` add/close paths so they apply selection when instructed (or via an explicit select command) rather than embedding strategy logic.
- Update DI / factories (`UseCaseRegistry`, `createTabsService`) so selection strategy is wired at the use-case boundary, not only into the data service.
- Preserve existing observable behavior (selected tab id notifications, tabs list updates) for UI consumers.
- Remove the issue #92 `#warning` / TODO from `CloseTabUseCase` once orchestration lives in the use case.

## Capabilities

### New Capabilities
- `write-tabs-selection`: Use-case orchestration for write operations that change the selected tab—add with optional immediate selection, and close with auto-selection of a remaining tab—while `TabsDataService` remains responsible for persistence and publishing state.

### Modified Capabilities
- (none)

## Impact

- **CottonTabs**: `TabsDataService` add/close handlers and `TabSelectionStrategy` injection; factory `DataServiceFactory.createTabsService`.
- **CottonUseCases**: `AddTabUseCase`, `CloseTabUseCase`, and/or new `WriteTabsUseCase`; strategy dependency and selection sequencing.
- **App DI**: `UseCaseRegistry`, possibly `ServiceRegistry` where the selection strategy is constructed.
- **View models / UI**: Prefer stable use-case APIs; rename/consolidate `writeTabUseCase` typing where it is currently aliased to `CloseTabUseCase` if a dedicated write use case is introduced.
- **Tests**: Unit-test selection policy at the use-case layer (Swift Testing); adjust any tabs data-service tests that assumed strategy lived inside the actor.
- **Out of scope**: Changing nearby vs other selection algorithms; closing all tabs / replace content / explicit user select (except as needed to apply a computed selection); ViewModelKit migrations.
