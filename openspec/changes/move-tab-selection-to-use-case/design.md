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
| `ReplaceSelectedTabUseCase` | `.replaceContent` forwarder | Same thicken direction (approved follow-up: move replace-content domain logic out of the data service) |

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
- Implementing replace-content / close-all / preview-update thickening **in this change** (approved as follow-ups; see Decision 7).
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

### 6. Cross-use-case composition (acyclic)

**Choice:** Use cases may depend on other use cases and/or data services. For this change:

| Edge | Verdict | Why |
|------|---------|-----|
| `CloseTabUseCase` → `SelectTabUseCase` | **Yes (required)** | Close owns *which* tab becomes selected (strategy + snapshot). Select owns *applying* that selection (persist + notify). Reuse `SelectTabUseCase` instead of calling `.selectTab` from Close or mutating selection inside the data-service close path. |
| `CloseTabUseCase` → `AddTabUseCase` | **Yes (preferred for last-tab)** | Last-tab recovery is “remove then add default.” Prefer composing `AddTabUseCase` so add-side selection policy stays in one place. |
| `AddTabUseCase` → `SelectTabUseCase` | **No (not needed)** | Add already drives selection via explicit `addTab(..., select:)` from `makeTabActiveAfterAdding`. A second Select call would be redundant. |
| `AddTabUseCase` → `CloseTabUseCase` | **No** | Would create a cycle with Close → Add. |
| `SelectTabUseCase` → Close/Add | **No** | Select stays a leaf that only talks to `TabsDataService`. |

If a DI cycle appears despite the above, extract a small shared helper or have Close call a service primitive for the default-tab add only as a fallback.

**Alternatives considered:**

- Close calls `.selectTab` on the data service directly — works, but duplicates Select’s error mapping and skips the dedicated use-case boundary.
- Fold selection apply into the close command again — re-mixes policy into the data service (rejects #92 goal).

### 7. Thicken `ReplaceSelectedTabUseCase` (follow-up)

**Choice:** Yes — `ReplaceSelectedTabUseCase` SHOULD move replace-content domain logic out of `TabsDataService` the same way add/close selection moved into use cases (guard selected tab, no-op when content unchanged, update + notify orchestration). Keep the data service as persistence/`ServiceData`/publish primitives. Close-all and preview-update (`SelectedTabUseCase`) follow the same pattern later.

**Out of scope for this change:** Implement that thickening in a follow-up; this change only locks the direction.

**Alternatives considered:**

- Leave replace forever as a thin `.replaceContent` proxy — rejected; same thin-proxy problem as #92.
- Fold replace into a combined write use case — rejected; keep the existing split APIs.

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

- (none)
