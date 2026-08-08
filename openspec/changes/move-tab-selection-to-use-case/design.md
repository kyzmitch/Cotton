## Context

`TabsDataService` mixes CRUD/persistence with selection policy:

- On **add**, it uses `selectionStrategy.makeTabActiveAfterAdding` and updates `selectedTabId` inside `handleTabAdded`.
- On **close**, `handleCachedTabRemove` calls `selectionStrategy.autoSelectedIndexAfterTabRemove(context: self, …)` (`TabsDataService` as `IndexSelectionContext`), then updates selection.

The write-side use cases are already split and are thin proxies today:

| Use case | Role today | Role after this change (selection focus) |
|----------|------------|------------------------------------------|
| `AddTabUseCase` | `.addTab` forwarder | Own select-after-add policy; drive service |
| `CloseTabUseCase` | `.closeTab` forwarder (+ #92 TODO) | Own reselect-after-close / last-tab recovery |
| `SelectTabUseCase` | `.selectTab` forwarder | Apply selection when add/close orchestration needs it |
| `ReplaceSelectedTabUseCase` | `.replaceContent` forwarder | Unchanged for selection; same “thicken later” direction |

Do **not** reintroduce a combined `WriteTabsUseCase`; that split is intentional.

Constraints: preserve observer/subject notifications; always keep ≥1 tab; keep `NearbySelectionStrategy` behavior equivalent; Swift Testing for new tests.

## Goals / Non-Goals

**Goals:**

- Move “decide next selected tab after add/close” into `AddTabUseCase` and `CloseTabUseCase`.
- Keep `TabsDataService` for repository I/O, `ServiceData`, and publishing mutations/selection when applied.
- Compose with `SelectTabUseCase` (or an explicit select command) when applying a computed selection, rather than hiding policy inside the data service.
- Make selection policy unit-testable at the use-case layer with fakes.

**Non-Goals:**

- Creating or restoring `WriteTabsUseCase`.
- Changing nearby selection algorithms.
- Moving close-all, preview update (`SelectedTabUseCase`), or replace-content domain logic in this change (follow-ups on the same thin-proxy problem).
- ViewModelKit / Observation migrations.
- Renaming all `writeTabUseCase` call-site locals (optional cleanup only).

## Decisions

### 1. Thicken existing split use cases (no aggregate write type)

**Choice:** Put selection orchestration in `AddTabUseCaseImpl` and `CloseTabUseCaseImpl`. Inject `TabSelectionStrategy` into those impls. When a new selection must be applied, call `SelectTabUseCase` (preferred, reuses validation/error mapping) or the data-service select command if a circular dependency appears.

**Alternatives considered:**

- New `WriteTabsUseCase` combining add+close — rejected; use cases were already split and callers depend on the split APIs.
- Leave strategy in the data service — does not address #92.

### 2. Data service becomes selection-policy agnostic

**Choice:** Remove `TabSelectionStrategy` from `TabsDataService` / `createTabsService`.

- **Add:** Accept explicit `select: Bool` from `AddTabUseCase` (strategy decides the flag). When true, update `selectedTabId` and notify as today.
- **Close:** Remove/publish tabs without strategy. Return enough for the use case (e.g. whether reselect is needed / remaining snapshot) **or** let `CloseTabUseCase` read state and then call `SelectTabUseCase`.
- **Select:** Existing `.selectTab` / `SelectTabUseCase` remains the apply path.

**Alternatives considered:** Service still owns strategy but is called from use cases — policy stays in infrastructure.

### 3. Snapshot `IndexSelectionContext` in the close use case

**Choice:** `CloseTabUseCase` builds a small snapshot `IndexSelectionContext` (last index + currently selected index from tabs after/before remove as required by strategy semantics) instead of using `TabsDataService` as the context.

**Alternatives considered:** Keep `TabsDataService: IndexSelectionContext` and call strategy from the actor — status quo.

### 4. Last-tab close in `CloseTabUseCase`

**Choice:** Orchestrate last-tab recovery in `CloseTabUseCase`: after removing the only tab, add a default-content tab (via `AddTabUseCase` or service add) and ensure it is selected (via strategy/`SelectTabUseCase`). Avoid leaving that policy only inside `handleCachedTabRemove`.

### 5. DI wiring

**Choice:** Construct `NearbySelectionStrategy` (or injected `TabSelectionStrategy`) in `UseCaseRegistry` for `AddTabUseCaseImpl` / `CloseTabUseCaseImpl`. Stop passing strategy into `DataServiceFactory.createTabsService`.

### 6. Shared helpers vs cross-use-case calls

**Choice:** Prefer `CloseTabUseCase` → `SelectTabUseCase` and, for last-tab, `CloseTabUseCase` → `AddTabUseCase` if dependency direction stays acyclic (`Add` must not depend on `Close`). If DI cycles appear, extract a small internal helper used by both add/close, or have close call service primitives for the default-tab add only.

## Risks / Trade-offs

- **[Risk] Double or missed selection notifications when add/close + select are split** → Mitigation: notify only on service paths that mutate `selectedTabId`; use cases always finish with an explicit select when policy requires it; cover with tests.
- **[Risk] DI cycle (Close → Add → …)** → Mitigation: last-tab add via service command from close, or shared package-private helper; do not make `AddTabUseCase` depend on `CloseTabUseCase`.
- **[Risk] Behavioral drift vs nearby strategy edge cases** → Mitigation: Swift Testing scenarios for add/close; keep strategy implementation unchanged.
- **[Trade-off] Extra round-trips (close then select)** → Acceptable for layering; same actor.

## Migration Plan

1. Enrich `AddTabUseCase` / `CloseTabUseCase` with strategy + orchestration; wire in `UseCaseRegistry`.
2. Refactor `TabsDataService` add/close to drop strategy; support explicit select-on-add and selection-free close.
3. Compose `SelectTabUseCase` where needed; remove #92 warning.
4. Update `createTabsService` / `ServiceRegistry`.
5. Tests + manual smoke (add, close selected/non-selected, last tab).
6. Rollback: revert use-case and service changes together.

## Open Questions

- For last-tab recovery, prefer `CloseTabUseCase` calling `AddTabUseCase` vs a direct service `.addTab` to avoid any DI subtlety?
- Should a follow-up change thicken `ReplaceSelectedTabUseCase` / close-all the same way (logic out of the data service)?
