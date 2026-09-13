## Why

`TabsDataService` loads tabs in its `init` and crashes (`fatalError`) when the initial load fails or hasn't finished, and its `tabs` / `selectedTabIdentifier` computed properties assume a `.finished(.success(...))` state. There is no safe, single-flight way for the first client of the service to trigger the initial load while concurrent callers await the same in-flight result instead of racing or re-fetching ([issue #97](https://github.com/kyzmitch/Cotton/issues/97)). `CommandExecutionData` already models that load cache: `.inProgress` holds the shared task, and `.finished` is the ready (or failed) result.

Mutating commands have the same gap. `handleAddTabCommand` (and close/select/replace) require `allTabs` and/or `selectedTabId` to already be `.finished(.success)`; if either is `.inProgress` they fail with `.noAnyTabs` / `.selectedNotFound` instead of waiting. Rapid add-tab taps are a second issue: `tabAdded` is written only as `.finished` (last write wins on the stored field), and the actor does **not** make the whole add atomic across `await`s.

## What Changes

- Use existing `CommandExecutionData<Input, Output, E>` as the cache entry. Do **not** introduce a new `CacheEntry` / `TabsCacheEntry` type for in-progress vs ready — those states are already `.inProgress(Task<Output, E>)` and `.finished(output: Result<Output, E>)`.
- Add the load (coalesce) start-or-join helper as an extension of `CommandExecutionData` in `GenericServiceKit`. Drive `TabsDataService`'s initial load through that helper on **both** `allTabs` and `selectedTabId` (and `tabsCount` derived with `allTabs`). Pre-seed `selectedTabId` as `.finished(.success(defaultSelectedTabId))` in `init` so the UI has instant data and does not wait for the repository. Then run `fetchSelectedTabId()` as `.inProgress` to replace that placeholder with the real id. If that call fails, restore `.finished(.success(defaultSelectedTabId))` — selected-id failure MUST NOT fail UI loading or stop the app from functioning. `allTabs` failure stays `.finished(.failure)` and retryable.
- Mutating handlers that need the cache (`handleAddTabCommand` and the other commands that guard on `allTabs` / `selectedTabId`) SHALL await whichever of those entries is `.inProgress` (one or both) instead of treating in-flight load as a missing cache.
- Serialize all mutations that write `allTabs` / `selectedTabId` through **one shared** `CommandExecutionData` on `TabsDataService` (not `tabAdded` / `tabClosed` / …). Wait-then-run, not coalesce: a later add/close/select awaits the in-flight mutation, then starts its own. Two add taps still add two tabs. Per-command fields stay last-write results returned by `sendCommand`. Do **not** add a pending-tabs queue — the actor plus wait-then-claim on that shared `.inProgress` is enough. The actor alone is not: `handleAddTabCommand` awaits the repository **before** writing `allTabs`, and Swift actors are reentrant at `await`.
- Keep existing `ServiceData` publishing, observer/subject notifications, and command API unchanged aside from populating `.inProgress` during the initial load and during an in-flight mutation.
- Unit tests (Swift Testing) covering: concurrent first load coalescing, cached read after `.finished(.success)`, retry after `.finished(.failure)`, mutating command waits for in-progress cache, and overlapping add-tab commands serialize (two adds → two tabs, no lost update).

## Capabilities

### New Capabilities
- `data-service-cache`: Single-flight in-memory caching of async loads for domain data services via existing `CommandExecutionData` (`.inProgress` / `.finished`) with coalesced concurrent access, immediate cached reads on success, retry after failure, mutating commands that await in-progress cache entries, and one shared wait-then-run mutation lock for anything that writes `allTabs` / `selectedTabId` (not coalesce, not per-command locks, not a separate queue).

### Modified Capabilities
- (none — no existing spec's requirements change; `TabsDataService` public command/observer behavior is preserved)

## Impact

- **CottonTabs**: `TabsDataService` pre-seeds `selectedTabId` with `defaultSelectedTabId` for instant UI, then loads `allTabs` / `tabsCount` / `selectedTabId` through `.inProgress`. Selected-id repository failure falls back to that default so the UI keeps working. Mutating command handlers await `.inProgress` cache entries and serialize through one shared `CommandExecutionData` lock local to the service. No new cache type, queue type, or public protocol changes.
- **GenericServiceKit**: `CommandExecutionData` cases stay as-is. The load (coalesce) helper is an extension of `CommandExecutionData` in this kit. The shared mutation lock and wait-then-start helper stay local to `TabsDataService`.
- **Tests**: Swift Testing coverage of the coalesce helper in `GenericServiceKitTests` (`.notStarted` / `.inProgress` / `.finished`), plus `TabsDataService` mutating-command wait-for-cache and overlapping `addTab` serialization; not a separate `CacheEntry` type.
- **Out of scope**: A new `CacheEntry` (or equivalent) enum; a pending-tabs queue; coalescing distinct `addTab` commands onto one task; persisted disk cache; caching for `SearchDataService`; changing `sendCommand` API; removing `CommandExecutionData`'s `.notStarted` / `.started` cases.
