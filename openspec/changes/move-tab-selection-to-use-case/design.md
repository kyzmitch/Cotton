## Context

Today `TabsDataService` mixes CRUD/persistence with selection policy:

- On **add**, it reads `selectionStrategy.makeTabActiveAfterAdding` and, when true, updates `selectedTabId` and notifies observers inside `handleTabAdded`.
- On **close**, `handleCachedTabRemove` calls `selectionStrategy.autoSelectedIndexAfterTabRemove(context: self, …)` (using `TabsDataService` as `IndexSelectionContext`), then updates selection and notifies.

Use cases (`AddTabUseCaseImpl`, `CloseTabUseCaseImpl`) only forward commands. `CloseTabUseCase` already carries `#warning("TODO: https://github.com/kyzmitch/Cotton/issues/92")`. Some view-model factories name a dependency `writeTabUseCase` but type it as `CloseTabUseCase`, which hints at a missing write orchestration type.

Constraints: preserve observer / subject notification behavior; keep at least one tab (last-tab close still seeds a default tab); `TabSelectionStrategy` / `NearbySelectionStrategy` behavior must stay equivalent; prefer Swift Testing for new unit tests.

## Goals / Non-Goals

**Goals:**

- Move “decide next selected tab after add/close” into the use-case layer.
- Keep `TabsDataService` responsible for repository I/O, in-memory `ServiceData`, and publishing tabs/selection changes when selection is applied.
- Expose a clear write API (prefer `WriteTabsUseCase`) that combines mutation + selection for add-with-select and close-with-reselect.
- Make selection policy unit-testable without spinning up the full tabs actor (strategy + use case with fakes).

**Non-Goals:**

- Changing `NearbySelectionStrategy` algorithms or introducing alternate strategies.
- Reworking explicit user `selectTab`, replace content, preview update, or close-all beyond what last-tab recovery already requires.
- ViewModelKit / Observation migrations.
- Broad rename of all “write” naming across the app unless required for the new use-case type.

## Decisions

### 1. Introduce `WriteTabsUseCase` for add/close + selection

**Choice:** Add `WriteTabsUseCase` (protocol + impl) that owns `TabSelectionStrategy` and orchestrates:

- `add(tab)` → persist add → if strategy says make active, apply selection to the new tab.
- `close(tab)` → persist remove → if selection must change, compute next id via strategy → apply selection (or handle last-tab default-tab path).

Keep existing `AddTabUseCase` / `CloseTabUseCase` as thin adapters that delegate to `WriteTabsUseCase` **or** migrate call sites to `WriteTabsUseCase` and deprecate the thin wrappers in the same change if touch set is small.

**Alternatives considered:**

- Only inject strategy into `AddTabUseCase` / `CloseTabUseCase` separately — simpler, but duplicates orchestration and misses the issue’s `WriteTabsUseCase` direction / existing `writeTabUseCase` naming.
- Leave selection inside the data service and only document it — does not address #92.

### 2. Data service becomes selection-agnostic for policy; still applies selection

**Choice:** Remove `TabSelectionStrategy` from `TabsDataService` init/factory. Add/close commands no longer consult the strategy.

- **Add:** Accept an explicit `select: Bool` (command payload or repository already has `add(tab, select:)`) driven by the use case; when `select` is true, update `selectedTabId` and notify as today.
- **Close:** Remove the tab from cache/repo and publish tabs list/count; do **not** compute next selection via strategy. Return enough info for the use case (e.g. closed tab id / whether it was selected / remaining tabs snapshot), or rely on follow-up read + `selectTab` from the use case.
- **Apply selection:** Reuse existing `.selectTab` (or a lightweight set-selected-id path) so notifications stay in one place.

**Alternatives considered:**

- Service returns “suggested” selection while still owning strategy — keeps policy in infrastructure.
- Use case mutates `ServiceData` directly — breaks actor encapsulation.

### 3. `IndexSelectionContext` for the use case, not the data service

**Choice:** Build a small sendable/value `IndexSelectionContext` (tabs count / selected index derived from a snapshot after close) inside the use case (or as a pure helper) when calling `autoSelectedIndexAfterTabRemove`. Stop requiring `TabsDataService: IndexSelectionContext` for this flow.

**Alternatives considered:** Keep context on the actor and call strategy from inside the service — status quo.

### 4. Last-tab close stays a write orchestration concern

**Choice:** When closing the only tab, the use case (or a dedicated step it invokes) still ensures a default blank/default-content tab exists and is selected. Prefer implementing that sequence in `WriteTabsUseCase` (close → add default → select) using data-service primitives, rather than a hidden side effect buried only in `handleCachedTabRemove`. If a short transitional helper remains in the service, document it as temporary and still trigger selection from the use case.

### 5. DI wiring

**Choice:** Construct `NearbySelectionStrategy` (or injected `TabSelectionStrategy`) in `UseCaseRegistry` when creating `WriteTabsUseCaseImpl`. Stop passing strategy into `DataServiceFactory.createTabsService`.

## Risks / Trade-offs

- **[Risk] Double notification or missed selection update during split add/close + select** → Mitigation: keep notification only on the service paths that mutate `selectedTabId`; use case always finishes with an explicit select when policy requires it; add focused tests for add-select and close-selected.
- **[Risk] Race if another writer mutates tabs between close and select** → Mitigation: tabs writes already go through the single `TabsDataService` actor; perform close+select as sequential awaits on that actor from one use-case execution; avoid overlapping unstructured Tasks in the use case.
- **[Risk] Behavioral drift vs `NearbySelectionStrategy` edge cases (close non-selected, close last index, etc.)** → Mitigation: port existing expectations into Swift Testing scenarios against the use case + fake service; keep strategy implementation unchanged.
- **[Risk] API churn for VMs typed as `CloseTabUseCase` / `AddTabUseCase`** → Mitigation: retain protocol façades that delegate to `WriteTabsUseCase`, or update factories in the same PR; prefer one approach and list call sites in tasks.
- **[Trade-off] Slightly more round-trips (close then select) vs monolithic service command** → Acceptable for clearer layering; same actor, low overhead.

## Migration Plan

1. Add `WriteTabsUseCase` + wire strategy in `UseCaseRegistry`.
2. Refactor `TabsDataService` add/close to drop strategy; support explicit select-on-add and selection-free close (plus existing select command).
3. Point `AddTabUseCase` / `CloseTabUseCase` (or call sites) at the write use case; remove #92 warning.
4. Update `createTabsService` signature and `ServiceRegistry`.
5. Add/adjust unit tests; manually smoke add tab, close selected, close non-selected, close last tab.
6. Rollback: revert use-case/service commits together (strategy must not be removed from service without the use-case owner).

## Open Questions

- Prefer migrating all call sites to `WriteTabsUseCase` in this change vs keeping `AddTabUseCase` / `CloseTabUseCase` as permanent delegating façades?
- Should close-all’s “reset to one selected tab” also move into `WriteTabsUseCase` in a follow-up, or stay in the data service for now (current non-goal)?
