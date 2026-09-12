## Why

`TabsDataService` loads tabs in its `init` and crashes (`fatalError`) when the initial load fails or hasn't finished, and its `tabs` / `selectedTabIdentifier` computed properties assume a `.finished(.success(...))` state. There is no safe, single-flight way for the first client of the service to trigger the initial load while concurrent callers await the same in-flight result instead of racing or re-fetching ([issue #97](https://github.com/kyzmitch/Cotton/issues/97)). `CommandExecutionData` already models that load cache: `.inProgress` holds the shared task, and `.finished` is the ready (or failed) result.

## What Changes

- Use existing `CommandExecutionData<Input, Output, E>` as the cache entry. Do **not** introduce a new `CacheEntry` / `TabsCacheEntry` type for in-progress vs ready — those states are already `.inProgress(Task<Output, E>)` and `.finished(output: Result<Output, E>)`.
- Drive `TabsDataService`'s initial load (`fetchTabs`) through that type (already used as `AllTabsData` / `SelectedTabData` on `TabsServiceData`): the first caller stores `.inProgress`, subsequent callers await the same task, success stores `.finished(.success)`, and failure is `.finished(.failure)` so the next caller can retry instead of joining a completed failed task.
- Keep existing `ServiceData` publishing, observer/subject notifications, and command API unchanged aside from populating `.inProgress` during the initial load.
- Unit tests (Swift Testing) covering: concurrent first load coalescing, cached read after `.finished(.success)`, retry after `.finished(.failure)`, and cache behavior on mutation.

## Capabilities

### New Capabilities
- `data-service-cache`: Single-flight in-memory caching of async loads for domain data services via existing `CommandExecutionData` (`.inProgress` / `.finished`) with coalesced concurrent access, immediate cached reads on success, and retry after failure.

### Modified Capabilities
- (none — no existing spec's requirements change; `TabsDataService` public command/observer behavior is preserved)

## Impact

- **CottonTabs**: `TabsDataService` initial-load path uses `CommandExecutionData` as the cache entry (the type already backing `serviceData.allTabs` and `serviceData.selectedTabId`). No new cache type and no public protocol changes.
- **GenericServiceKit**: `CommandExecutionData` cases stay as-is. Optional awaiting / start-or-join helpers may be added as an extension of `CommandExecutionData` (no new type).
- **Tests**: Swift Testing coverage of single-flight load behavior against `CommandExecutionData` states (`.notStarted` / `.inProgress` / `.finished`), not a separate `CacheEntry` type.
- **Out of scope**: A new `CacheEntry` (or equivalent) enum; persisted disk cache; caching for `SearchDataService`; changing `sendCommand` API; removing `CommandExecutionData`'s `.notStarted` / `.started` cases.
