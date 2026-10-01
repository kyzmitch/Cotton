## Why

`TabsDataService` currently owns both tab persistence and selection policy (select a newly added tab; recompute selection after closing via `TabSelectionStrategy`). The write-side use cases—`AddTabUseCase`, `CloseTabUseCase`, `SelectTabUseCase`, and `ReplaceSelectedTabUseCase`—are thin command proxies and do not own that orchestration. `CloseTabUseCase` already has an open TODO for [issue #92](https://github.com/kyzmitch/Cotton/issues/92). Selection (and, over time, other domain logic) belongs in those existing use cases so the data service stays focused on storage, `ServiceData`, and publishing.

## What Changes

- Move post-mutation tab selection out of `TabsDataService` into the **existing** use cases (no new `WriteTabsUseCase`):
  - `AddTabUseCase` decides whether the new tab becomes selected (`TabSelectionStrategy.makeTabActiveAfterAdding`) and applies selection (directly or via `SelectTabUseCase`).
  - `CloseTabUseCase` computes the next selected tab after remove (`autoSelectedIndexAfterTabRemove`) and applies it (including last-tab → default tab).
  - `SelectTabUseCase` remains the shared path to apply an explicit selection when orchestration needs it.
- Slim `TabsDataService` add/close paths so they do not embed `TabSelectionStrategy`; they persist and publish when selection is requested or applied through select.
- Wire `TabSelectionStrategy` at the use-case boundary (`UseCaseRegistry`), not into `createTabsService`.
- Preserve observer/subject behavior for tabs list and selected tab id.
- Remove the issue #92 `#warning` from `CloseTabUseCase` once close orchestration owns selection.
- **Direction (this change starts it):** thicken the split write use cases instead of re-aggregating them; `ReplaceSelectedTabUseCase` is approved to pull replace-content domain logic out of `TabsDataService` in a follow-up (same layering as add/close selection).

## Capabilities

### New Capabilities
- `tabs-use-case-selection`: Selection-after-add and selection-after-close live in `AddTabUseCase` / `CloseTabUseCase` (composing `SelectTabUseCase` as needed); `TabsDataService` no longer owns `TabSelectionStrategy` for those flows.

### Modified Capabilities
- (none)

## Impact

- **CottonTabs**: `TabsDataService` add/close handlers; remove strategy from service init/`DataServiceFactory.createTabsService`.
- **CottonUseCases**: Enrich `AddTabUseCase`, `CloseTabUseCase`; may compose `SelectTabUseCase`; DI for `TabSelectionStrategy`. `ReplaceSelectedTabUseCase` thickening is an approved follow-up.
- **App DI**: `UseCaseRegistry`, `ServiceRegistry` strategy wiring.
- **View models / UI**: Keep existing `AddTabUseCase` / `CloseTabUseCase` / `SelectTabUseCase` APIs; no migration to a combined write type. Optional cleanup of misleading `writeTabUseCase` parameter names that type as `CloseTabUseCase`.
- **Tests**: Swift Testing for add/close selection at the use-case layer; adjust data-service tests that assumed strategy lived in the actor.
- **Out of scope (this change)**: New aggregate `WriteTabsUseCase`; changing `NearbySelectionStrategy` algorithms; implementing replace / close-all / preview-update logic moves (follow-ups); ViewModelKit migrations.
