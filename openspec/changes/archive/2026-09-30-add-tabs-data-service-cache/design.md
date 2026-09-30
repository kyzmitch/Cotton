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
- Single-flight initial load for **both** `allTabs` and `selectedTabId`. Pre-seed selected tab id with `defaultSelectedTabId` for instant UI; after `.inProgress`, repository failure falls back to that default so the UI keeps working.
- Mutating commands await in-progress `allTabs` / `selectedTabId` instead of failing; one shared mutation lock wait-then-runs overlapping add/close/select (two add taps → two tabs).
- Load (coalesce) start-or-join helper as an extension of `CommandExecutionData` in `GenericServiceKit`; mutation wait-then-start stays local to `TabsDataService`.
- No new cache-entry enum and no pending-tabs queue.

**Non-Goals:**
- Introducing `CacheEntry` / `TabsCacheEntry` or any other 2-case stand-in for in-progress/ready.
- Disk / persisted cache (in-memory only).
- Time-based (TTL) expiry or capacity/LRU policies.
- Caching for other services (`SearchDataService`) — the type is already reusable; adoption is out of scope.
- Changing `sendCommand` API or removing `.notStarted` / `.started` from `CommandExecutionData`.
- A pending-tabs queue type, or coalescing two `addTab` commands onto one task (two taps must add two tabs).
- Changing `sendCommand`’s return shape (`tabAdded` stays a single last-write field; each caller still receives the snapshot returned from its own `sendCommand`).

## Decisions

### D1: Reuse `CommandExecutionData` as the cache entry; do not add a new type
The issue sketches `TabsCacheEntry` with `.inProgress` / `.ready`. `CommandExecutionData` already has `.inProgress(Task<Output, E>)` and `.finished(output: Result<Output, E>)`. `.finished(.success)` is the ready cache; `.notStarted` is the cold/empty state (no need for an optional wrapper). `TabsListError` already conforms to `DataServiceKitError`, and `AllTabsData` / `SelectedTabData` are already this type.

*Alternative considered:* a dedicated 2-case `CacheEntry<Value>` — rejected. It duplicates states the kit already models and would sit beside `serviceData.allTabs`, which is already the tabs cache.

### D2: Cache storage is the existing `CommandExecutionData` fields on `TabsServiceData`
`TabsDataService` is already an actor, so `serviceData.allTabs` / `serviceData.selectedTabId` are serialized with no extra hop. A second cache actor or a parallel optional property of a new type would duplicate the source of truth.

*Alternative considered:* a private `CacheEntry<[Tab]>?` next to `serviceData` — rejected once D1 chose `CommandExecutionData`. A private `CommandExecutionData` copy would still duplicate `allTabs`.

### D3: Cold is `.notStarted`; failure is `.finished(.failure)` and retryable
Observable states: `.notStarted` (never loaded / reset), `.inProgress(task)` (load started), `.finished(.success)` (cached), `.finished(.failure)` (last load failed). A later load request treats `.finished(.failure)` like cold cache and starts a fresh `.inProgress` task, so callers never await a completed failed task stuck in `.inProgress`.

### D4: Load coalesce helper lives on `CommandExecutionData` in `GenericServiceKit`
The load (coalesce) start-or-join helper is an extension of `CommandExecutionData` in `GenericServiceKit`: `.inProgress` awaits and returns that result; `.notStarted` / `.finished(.failure)` start a new load; `.finished(.success)` returns the cached value. That matches the codebase rule of extending the input/output type, and keeps the helper reusable for any data service that already stores `CommandExecutionData`.

The mutation wait-then-start helper is **not** this API. It stays local to `TabsDataService` and operates on the shared mutation lock (D7). Two helpers so load join and mutation join cannot be mixed up.

*Alternative considered:* a file-local extension in `CottonTabs` only — rejected; coalesce is generic over `CommandExecutionData` and belongs next to the type.

### D5: Initial load moves out of crash-prone `init` path gradually
The service keeps loading in `init` (so existing app-start behavior is unchanged), but each cache field goes through `.inProgress` so re-entrant/later consumers coalesce instead of re-fetching. The `fatalError` on unfinished state in `tabs` is out of scope to remove wholesale in this change; the cache provides the safe await path.

Keep pre-seeding `serviceData.selectedTabId = .finished(.success(defaultSelectedTabId))` in `init` so the UI has instant selected-tab data. That placeholder is not a repository cache hit: `fetchSelectedTabId()` still runs and moves the field to `.inProgress`. The generic coalesce helper’s “`.finished(.success)` means do not reload” applies to later callers, not to this explicit init fetch.

### D6: Mutating commands await `.inProgress` cache instead of failing
`handleAddTabCommand` today `guard`s that `allTabs` and `selectedTabId` are both `.finished(.success)` and otherwise sets `tabAdded` to `.failure(.noAnyTabs)`. Once `fetchTabs` stores `.inProgress`, an add (or close/select/replace) during the initial load would spuriously fail. Handlers that need those fields await whichever is `.inProgress` (one or both), then mutate. `.finished(.failure)` still fails the mutation — there is no tabs list to edit.

### D7: One shared mutation lock, not per-command `.inProgress`
Add, close, select, replace, and preview all write `allTabs` and/or `selectedTabId`. One in-flight mutation must exclude the others. A private `CommandExecutionData<Void, Void, TabsListError>` (or equivalent) on `TabsDataService` is that lock:

- Wait-then-claim: `while .inProgress { await }; store .inProgress` before the repository `await`; finish the lock when the mutation completes.
- Two add taps still add two tabs (do not coalesce onto the in-flight task).
- Close during an add waits on the **same** entry, so it cannot copy the pre-add array. Per-command fields (`tabAdded.inProgress`, `tabClosed.inProgress`, …) cannot express that: an add would not see a close’s lock and vice versa, unless every handler polled every field.
- `tabAdded` / `tabClosed` / … stay last-write results on `ServiceData`. `sendCommand` still returns that snapshot; the lock is not published.
- No pending-`Tab` queue. The actor mailbox plus wait-then-claim is FIFO.

The helper that talks to this lock stays local to `TabsDataService`. It is not a `GenericServiceKit` API.

*Alternative considered:* per-command `.inProgress` on `tabAdded` / `tabClosed` / … — rejected; cross-command races on shared cache need one lock, not N. *Alternative considered:* a dedicated add-tab queue — rejected as extra machinery. *Alternative considered:* rely on the actor alone — rejected because of reentrancy at `await` before `allTabs` is updated. *Alternative considered:* publish the lock on `TabsServiceData` — rejected; it is not a command result and would change the public snapshot for no consumer benefit.

### D8: `selectedTabId` is a first-class `.inProgress` cache with a default fallback
The app needs a selected tab at start immediately, and `fetchSelectedTabId()` can fail while `fetchAllTabs()` succeeds. Therefore:

- `init` pre-seeds `.finished(.success(defaultSelectedTabId))` so the UI does not wait.
- The real load still uses `.inProgress` for `fetchSelectedTabId()` (or the empty-tabs path that adds a default tab and uses that tab’s id). Concurrent readers coalesce on that task.
- On success, store `.finished(.success(realId))`.
- On repository failure, restore `.finished(.success(defaultSelectedTabId))` — the same initial value. The in-flight `Task` completes with that fallback (not a thrown error) so waiters and the UI keep working. Do not leave `.finished(.failure)` on `selectedTabId`; that would fail UI loading.
- `allTabs` / `tabsCount` do not get this fallback: their failure stays `.finished(.failure)` and is retryable.

*Alternative considered:* one combined start-info entry written at the end of `fetchTabs` — rejected; selected tab would not have its own in-flight task. *Alternative considered:* no pre-seed, only `.inProgress` then `.finished(.failure)` — rejected; the UI would wait or break when the selected-id repository fails.

## Risks / Trade-offs

- [Task cancellation: a caller awaiting `.inProgress(task)` that gets cancelled must not poison the entry for others] → Await with `Task<...>.value` semantics carefully; cancellation of one waiter does not cancel the shared task; document that the shared task is only cancelled if the initiating context is cancelled. Keep promotion-to-`.finished` in the actor regardless of which waiter resumes first.
- [Stale cache after external mutations] → Mutating commands still write through to the repository; they now await in-progress `allTabs` / `selectedTabId` instead of failing, and serialize overlapping mutations via wait-then-claim on `.inProgress`. They do not bypass an in-flight initial load.
- [Actor is not a command queue] → `TabsDataService` being an actor serializes isolated state only between `await`s. `handleAddTabCommand` awaits `tabsRepository.add` before assigning `serviceData.allTabs`, so a second `sendCommand(.addTab)` (or a close) can interleave and copy a stale array. Wait-then-claim on the **shared** mutation lock closes that window without a `Tab` queue.
- [`.inProgress` coalesce vs mutex] → Load cache (`allTabs`) coalesces: many readers, one fetch. The shared mutation lock must not coalesce: many commands, many tasks, run one after another. Same enum, different join semantics (await-and-return vs await-then-start).
- [Publishing `.inProgress` on `serviceData`] → `allTabs`, `tabsCount`, and `selectedTabId` may briefly be `.inProgress` during the first load. Command API and observer/subject notifications on completion stay the same; the `tabs` getter still `fatalError`s until `.finished(.success)`.
- [Selected tab id fetch failure] → Restore the pre-seeded `defaultSelectedTabId` as `.finished(.success)` and complete the in-flight task with that id. UI loading and later mutations must not fail because the selected-id repository failed. `allTabs` failure is still fatal to that load / retryable.

## Migration Plan

1. Add the load (coalesce) helper as an extension of `CommandExecutionData` in `GenericServiceKit`, with unit tests in `GenericServiceKitTests`. Mutation wait-then-start stays local to `TabsDataService`.
2. Pre-seed `selectedTabId` with `defaultSelectedTabId`. Route `fetchAllTabs()` / `fetchSelectedTabId()` through `.inProgress` on `allTabs` (and derived `tabsCount`) and `selectedTabId`. On selected-id failure, restore the default `.finished(.success)`. Preserve observer notifications on successful completion.
3. Change mutating handlers to await in-progress `allTabs` / `selectedTabId`, and serialize them through one shared mutation `CommandExecutionData` on `TabsDataService` (wait-then-claim; per-command fields stay results only).
4. Run existing `CottonUseCasesTests` / domain tests to confirm no behavior change; add new concurrency tests (load coalesce vs mutation serialize).
5. Rollback: revert the single commit(s); no data migration involved.

## Resolved decisions (former open questions)

- **Shared mutation lock vs per-command fields:** one shared `CommandExecutionData` on `TabsDataService` for every mutation that writes `allTabs` / `selectedTabId`. Per-command `ServiceData` fields are results, not locks. Helper stays local to `TabsDataService` (D7).
- **Load coalesce helper location:** extension of `CommandExecutionData` in `GenericServiceKit` (D4). Mutation wait-then-start stays local to `TabsDataService`.
- **`.inProgress` for `fetchSelectedTabId()`:** yes, as its own cache entry (D8). Pre-seed `.finished(defaultSelectedTabId)` for instant UI; after `.inProgress`, repository failure falls back to that same default so the UI keeps working. `allTabs` failure stays `.finished(.failure)`.
