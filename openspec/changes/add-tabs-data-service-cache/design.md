## Context

`TabsDataService` (an actor in `CottonTabs`) performs its initial tabs load inside `init` via `fetchTabs()`, storing results in `serviceData` (`TabsServiceData`). Accessors like the `tabs` computed property `fatalError` when `serviceData.allTabs` is not `.finished(.success(...))`, so any consumer reading before the initial load completes crashes the app. Concurrent callers have no way to await the same in-flight load — the first caller triggers the work, but there is no shared handle other than `serviceData` state, which is set only after completion.

[Issue #97](https://github.com/kyzmitch/Cotton/issues/97) asks for a small in-memory, single-flight cache: the first client of `TabsDataService` initiates loading, and any subsequent calls await the very first call's `Task` result. The issue sketches a `TabsCacheEntry` enum with `.inProgress(Task<[Tab], Error>)` and `.ready([Tab])`.

Related prior art in the codebase: `GenericServiceKit.CommandExecutionData` already models an `inProgress(Task<Output, E>)` case for command execution state. That type is input/output-shaped for commands and bound to `DataServiceKitError`; the cache needs a standalone, load-shaped value type.

Constraints:
- `TabsDataService` is an actor — its stored properties are already serialized, which is where the cache entry lives.
- Swift Testing is the test framework for new unit tests; SwiftLint rules apply (`catowseriOS/.swiftlint.yml`).
- Public `TabsDataServiceProtocol` / `sendCommand` API and observer/subject behavior must not change.

## Goals / Non-Goals

**Goals:**
- A generic, `Sendable` `CacheEntry<Value>` enum with `.inProgress(Task<Value, Error>)` and `.ready(Value)` states.
- Single-flight initial tabs load: concurrent callers coalesce onto one repository load; success caches, failure clears the entry so the next caller retries.
- Safe reads: consumers can await tabs data instead of crashing on unfinished state.
- Reusable for any async load (e.g., `[Tab]`, selected tab id) without binding to `TabsListError`.

**Non-Goals:**
- Disk / persisted cache (in-memory only).
- Time-based (TTL) expiry or capacity/LRU policies.
- Caching for other services (`SearchDataService`) — pattern is reusable, adoption is out of scope.
- Changing `ServiceData` semantics, `sendCommand` API, or `CommandExecutionData`.
- Caching post-init mutations (add/close/select still write through to the repository and update `serviceData` directly).

## Decisions

### D1: Generic `CacheEntry<Value>` enum, not a `[Tab]`-specific one
The issue sketches `TabsCacheEntry`, but the state machine (in-flight task vs. ready value) is domain-agnostic. A generic `CacheEntry<Value: Sendable>` keeps it reusable and testable in isolation. Error type stays `Error` (untyped) to match the issue sketch and avoid forcing a repository-specific failure type into the cache layer.

*Alternative considered:* reuse `CommandExecutionData` — rejected because it carries `Input` and a `DataServiceKitError`-bound `E`, and models command state (`notStarted`/`started`/`finished`) rather than single-flight load state. A dedicated 2-case enum is minimal and exactly fits.

### D2: Cache storage lives as actor-isolated optional properties, not a separate cache actor
`TabsDataService` is already an actor, so `private var tabsCacheEntry: CacheEntry<[Tab]>?` gets serialization for free and no hop. Introducing a second cache actor would add indirection and an extra isolation domain without benefit.

*Alternative considered:* a standalone `InMemoryCache<Value>` actor wrapping one entry — rejected as needless machinery when the host is already an actor. The enum itself is the reusable unit; hosts hold it as an optional.

### D3: `nil` entry means "not loaded"; failure resets to `nil` (retry semantics)
Three observable states: `nil` (never loaded / last load failed), `.inProgress(task)` (load started), `.ready(value)` (loaded). On task failure the entry is cleared so the next caller starts a fresh load, matching the issue sketch.

### D4: Awaiting helpers as `CacheEntry` extension
A single `func value() async throws -> Value` (or equivalent) on `CacheEntry` that awaits the in-flight task and returns the ready value lets each call site handle one enum and keeps the "start-or-join then promote to ready" logic in one place, following the codebase's preference for extensions co-located with the type.

### D5: Initial load moves out of crash-prone `init` path gradually
The service keeps loading in `init` (so existing app-start behavior is unchanged), but the load goes through the cache entry so any re-entrant/later consumers coalesce instead of re-fetching. The `fatalError` on unfinished state in `tabs` is out of scope to remove wholesale in this change; the cache provides the safe await path.

## Risks / Trade-offs

- [Task cancellation: a caller awaiting `.inProgress(task)` that gets cancelled must not poison the entry for others] → Await with `Task<...>.value` semantics carefully; cancellation of one waiter does not cancel the shared task; document that the shared task is only cancelled if the initiating context is cancelled. Keep promotion-to-`ready`/reset-to-`nil` in the actor regardless of which waiter resumes first.
- [Stale cache after external mutations] → Mutating commands (add/close/select/close-all) already write through to the repository and update `serviceData`; they bypass the cache entry by design since they own authoritative state. The cache entry is for the initial/async load path only.
- [Unowned `Error` type loses typed throws] → Acceptable; the repository call sites already throw untyped `Error`; the service maps to `TabsListError.repositoryFailure` at the boundary as today.
- [Generic enum in `CottonTabs` is tabs-module-local for now] → If `SearchDataService` or others adopt it later, moving to `GenericServiceKit` is a mechanical move; keeping it out now avoids speculative generalization in a shared kit.

## Migration Plan

1. Add `CacheEntry<Value>` (new file in `CottonTabs`), with unit tests.
2. Add cache entry property + single-flight load helper to `TabsDataService` (internal only).
3. Route `fetchTabs()`'s repository reads through the cache entry (tabs array and selected tab id where applicable), preserving all `serviceData` writes and observer notifications.
4. Run existing `CottonUseCasesTests` / domain tests to confirm no behavior change; add new concurrency tests.
5. Rollback: revert the single commit(s); no data migration involved.

## Open Questions

- Should `.inProgress` retention also cover `fetchSelectedTabId()` (second repository call in the initial load), or only the tabs array? Initial implementation: cache the combined start-info load as one entry (tabs + selected id are fetched together in `fetchTabs`).
- Naming: `CacheEntry` vs `TabsCacheEntry` — going with generic `CacheEntry<Value>` per D1; revisit if it ever moves to `GenericServiceKit` (could become `ServiceKitCacheEntry`).
