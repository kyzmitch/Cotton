## Context

`TabsDataService` (an actor in `CottonTabs`) performs its initial tabs load inside `init` via `fetchTabs()`, storing results in `serviceData` (`TabsServiceData`). Accessors like the `tabs` computed property `fatalError` when `serviceData.allTabs` is not `.finished(.success(...))`, so any consumer reading before the initial load completes crashes the app. Concurrent callers have no way to await the same in-flight load — `fetchTabs()` jumps from `.notStarted` to `.finished` without ever storing `.inProgress`.

[Issue #97](https://github.com/kyzmitch/Cotton/issues/97) asks for a small in-memory, single-flight cache: the first client of `TabsDataService` initiates loading, and any subsequent calls await the very first call's `Task` result. The issue sketches a `TabsCacheEntry` enum with `.inProgress(Task<[Tab], Error>)` and `.ready([Tab])`.

Those two states already exist on `GenericServiceKit.CommandExecutionData`: `.inProgress(Task<Output, E>)` and `.finished(output: Result<Output, E>)` (success is the ready cache; failure is a recorded error that can be retried). `TabsServiceData.allTabs` / `selectedTabId` are already `CommandExecutionData` and are documented as the tabs / selected-id cache.

Constraints:
- `TabsDataService` is an actor — its stored properties are already serialized, which is where the cache entry lives.
- Swift Testing is the test framework for new unit tests; SwiftLint rules apply (`catowseriOS/.swiftlint.yml`).
- Public `TabsDataServiceProtocol` / `sendCommand` API and observer/subject behavior must not change.

## Goals / Non-Goals

**Goals:**
- Reuse `CommandExecutionData` as the cache entry: `.inProgress` for the shared in-flight task, `.finished(.success)` for the ready value, `.finished(.failure)` for a failed load that the next caller may retry.
- Single-flight initial tabs load: concurrent callers coalesce onto one repository load.
- Safe reads: consumers can await tabs data instead of crashing on unfinished state.
- No new cache-entry enum.

**Non-Goals:**
- Introducing `CacheEntry` / `TabsCacheEntry` or any other 2-case stand-in for in-progress/ready.
- Disk / persisted cache (in-memory only).
- Time-based (TTL) expiry or capacity/LRU policies.
- Caching for other services (`SearchDataService`) — the type is already reusable; adoption is out of scope.
- Changing `sendCommand` API or removing `.notStarted` / `.started` from `CommandExecutionData`.
- Caching post-init mutations (add/close/select still write through to the repository and update `serviceData` directly).

## Decisions

### D1: Reuse `CommandExecutionData` as the cache entry; do not add a new type
The issue sketches `TabsCacheEntry` with `.inProgress` / `.ready`. `CommandExecutionData` already has `.inProgress(Task<Output, E>)` and `.finished(output: Result<Output, E>)`. `.finished(.success)` is the ready cache; `.notStarted` is the cold/empty state (no need for an optional wrapper). `TabsListError` already conforms to `DataServiceKitError`, and `AllTabsData` / `SelectedTabData` are already this type.

*Alternative considered:* a dedicated 2-case `CacheEntry<Value>` — rejected. It duplicates states the kit already models and would sit beside `serviceData.allTabs`, which is already the tabs cache.

### D2: Cache storage is the existing `CommandExecutionData` fields on `TabsServiceData`
`TabsDataService` is already an actor, so `serviceData.allTabs` / `serviceData.selectedTabId` are serialized with no extra hop. A second cache actor or a parallel optional property of a new type would duplicate the source of truth.

*Alternative considered:* a private `CacheEntry<[Tab]>?` next to `serviceData` — rejected once D1 chose `CommandExecutionData`. A private `CommandExecutionData` copy would still duplicate `allTabs`.

### D3: Cold is `.notStarted`; failure is `.finished(.failure)` and retryable
Observable states: `.notStarted` (never loaded / reset), `.inProgress(task)` (load started), `.finished(.success)` (cached), `.finished(.failure)` (last load failed). A later load request treats `.finished(.failure)` like cold cache and starts a fresh `.inProgress` task, so callers never await a completed failed task stuck in `.inProgress`.

### D4: Awaiting helpers as `CommandExecutionData` extension
A helper (e.g. `value()` / start-or-join) on `CommandExecutionData` that awaits `.inProgress`, returns `.finished(.success)`, and treats `.notStarted` / `.finished(.failure)` as "start a new load" keeps call sites on one type, following the codebase's preference for extensions on the input/output type.

### D5: Initial load moves out of crash-prone `init` path gradually
The service keeps loading in `init` (so existing app-start behavior is unchanged), but the load goes through `.inProgress` so any re-entrant/later consumers coalesce instead of re-fetching. The `fatalError` on unfinished state in `tabs` is out of scope to remove wholesale in this change; the cache provides the safe await path.

## Risks / Trade-offs

- [Task cancellation: a caller awaiting `.inProgress(task)` that gets cancelled must not poison the entry for others] → Await with `Task<...>.value` semantics carefully; cancellation of one waiter does not cancel the shared task; document that the shared task is only cancelled if the initiating context is cancelled. Keep promotion-to-`.finished` in the actor regardless of which waiter resumes first.
- [Stale cache after external mutations] → Mutating commands (add/close/select/close-all) already write through to the repository and update `serviceData` as `.finished(.success)`; they bypass the in-flight load path by design. The `.inProgress` path is for the initial/async load only.
- [Publishing `.inProgress` on `serviceData`] → `allTabs` may briefly be `.inProgress` during the first load. Command API and observer/subject notifications on completion stay the same; the `tabs` getter still `fatalError`s until `.finished(.success)`.
- [Typed `E: DataServiceKitError` vs untyped `Error` in the issue sketch] → Acceptable and preferable; repository call sites already map to `TabsListError.repositoryFailure` at the service boundary.

## Migration Plan

1. Add start-or-join / await helpers on `CommandExecutionData` if needed (extension in `GenericServiceKit` or co-located in `CottonTabs` if file-local), with unit tests.
2. Route `fetchTabs()` through `.inProgress` on the existing `CommandExecutionData` fields, preserving all `serviceData` writes and observer notifications on completion.
3. Run existing `CottonUseCasesTests` / domain tests to confirm no behavior change; add new concurrency tests.
4. Rollback: revert the single commit(s); no data migration involved.

## Open Questions

- Should `.inProgress` retention also cover `fetchSelectedTabId()` (second repository call in the initial load), or only the tabs array? Initial implementation: cache the combined start-info load as one entry (tabs + selected id are fetched together in `fetchTabs`).
- Should the start-or-join helper live on `CommandExecutionData` in `GenericServiceKit` (reusable) or only in `TabsDataService`? Prefer an extension of `CommandExecutionData` if more than one call site needs it.
