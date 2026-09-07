## Why

`TabsDataService` loads tabs in its `init` and crashes (`fatalError`) when the initial load fails or hasn't finished, and its `tabs` / `selectedTabIdentifier` computed properties assume a `.finished(.success(...))` state. There is no safe, single-flight way for the first client of the service to trigger the initial load while concurrent callers await the same in-flight result instead of racing or re-fetching ([issue #97](https://github.com/kyzmitch/Cotton/issues/97)). A generic `CacheEntry<T>` coalesces concurrent loads and serves cached results without duplicating work.

## What Changes

- Introduce a generic `CacheEntry<Value>` enum (Sendable) in `CottonTabs` with two states:
  - `.inProgress(Task<Value, Error>)` — a load is in flight; awaiting callers wait on the same task
  - `.ready(Value)` — a value is cached and returned immediately
- Add a small in-memory cache container (`actor`-isolated storage holding `CacheEntry<T>` optionals) usable by `TabsDataService` for `[Tab]` and selected tab id loads.
- Wire the cache into `TabsDataService` so its initial load (`fetchTabs`) is single-flight: the first caller starts the task, subsequent callers await the in-flight task, and a failure clears the entry so the next caller retries.
- Keep existing `ServiceData` publishing, observer/subject notifications, and command API unchanged — the cache is an internal implementation detail.
- Unit tests (Swift Testing) covering: concurrent first load coalescing, cached read after success, retry after failure, and cache invalidation on mutation.

## Capabilities

### New Capabilities
- `data-service-cache`: Single-flight in-memory caching of async loads for domain data services via a generic `CacheEntry<T>` (`inProgress`/`ready`) with coalesced concurrent access, immediate cached reads, and error-clearing for retry.

### Modified Capabilities
- (none — no existing spec's requirements change; `TabsDataService` public command/observer behavior is preserved)

## Impact

- **CottonTabs**: New `CacheEntry.swift` (or similar) with the generic enum and cache store; `TabsDataService` initial-load path uses it. No public protocol changes.
- **GenericServiceKit**: Unaffected — `CommandExecutionData` remains as-is; `CacheEntry<T>` is a separate, purpose-built value type (single-flight load state, not command execution state).
- **Tests**: New `Domain/Tests/CottonTabsTests/` (or appropriate target) with `CacheEntry` behavior tests using Swift Testing.
- **Out of scope**: Persisted disk cache; caching for `SearchDataService`; changing `ServiceData` semantics or the `sendCommand` API; replacing `CommandExecutionData`'s `inProgress` semantics.
