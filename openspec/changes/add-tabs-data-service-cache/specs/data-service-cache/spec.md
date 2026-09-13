## ADDED Requirements

### Requirement: CommandExecutionData is the cache entry
The system SHALL use existing `CommandExecutionData<Input, Output, E>` as the in-memory cache entry for a single async load. It MUST NOT introduce a separate `CacheEntry`, `TabsCacheEntry`, or equivalent type whose only purpose is to model in-progress vs ready states.

Cache semantics map onto existing cases:
- `.inProgress(Task<Output, E>)` — a load is currently executing; the task is the shared handle to its result.
- `.finished(output: .success(value))` — a value has been loaded and is cached (the ready state).
- `.finished(output: .failure(error))` — the load failed; the failure is recorded so callers observe the error and a later request can retry.

`CommandExecutionData` SHALL remain `Sendable`.

The load (coalesce) start-or-join helper SHALL be an extension of `CommandExecutionData` in `GenericServiceKit`. It MUST NOT be a free function or a `TabsDataService`-only type. The mutation wait-then-start helper MUST remain local to `TabsDataService`.

#### Scenario: In-progress state holds shared task
- **WHEN** a load has been started and not yet finished
- **THEN** the cache entry is `.inProgress` holding the `Task<Output, E>` that any caller can await to obtain the same result

#### Scenario: Finished success is the ready state
- **WHEN** a load has completed successfully
- **THEN** the cache entry is `.finished(output: .success(value))` and exposes the loaded `Output` without re-executing any load

#### Scenario: Coalesce helper lives on CommandExecutionData
- **WHEN** a caller starts or joins an async load
- **THEN** it uses the `CommandExecutionData` extension in `GenericServiceKit`, not a CottonTabs-only helper or a free function

### Requirement: First caller initiates load
When the cache entry is `.notStarted`, the system SHALL start the underlying async load by creating a `Task<Output, E>`, store it as `.inProgress`, and await its result.

#### Scenario: Cold cache starts load
- **WHEN** the cache entry is `.notStarted` and a load is requested
- **THEN** exactly one load task is created and stored as `.inProgress` before awaiting

### Requirement: Concurrent callers coalesce onto in-flight load
When a load is `.inProgress`, any subsequent caller MUST await the existing task's result instead of starting a new load.

#### Scenario: Concurrent first loads share one task
- **WHEN** multiple callers request the load while the entry is `.inProgress`
- **THEN** the underlying load executes exactly once and all callers receive the same result

### Requirement: Successful load is cached as finished
When the awaited task completes successfully, the system SHALL store `.finished(output: .success(value))` so subsequent callers receive the value immediately without re-loading.

#### Scenario: Cached read after success
- **WHEN** the entry is `.finished(output: .success(value))` and a load is requested
- **THEN** the cached value is returned without invoking the load closure/task again

#### Scenario: Entry promoted after await
- **WHEN** a caller awaiting an `.inProgress` task receives a successful result
- **THEN** the entry transitions to `.finished(output: .success(value))`

### Requirement: Failed load is finished failure and retryable
When the awaited task fails, the system SHALL store `.finished(output: .failure(error))` (not leave a completed failed task in `.inProgress`). A subsequent load request SHALL treat `.finished(.failure)` like a cold cache and start a fresh `.inProgress` load.

#### Scenario: Retry after failure
- **WHEN** a load task fails and a subsequent load is requested
- **THEN** the entry is not `.inProgress` with a completed failed task, and a new load is started

#### Scenario: Concurrent callers observe failure
- **WHEN** multiple callers await an `.inProgress` task that ultimately fails
- **THEN** all callers receive the error and the entry is `.finished(.failure)` until the next attempt

### Requirement: TabsDataService uses CommandExecutionData for initial load
`TabsDataService` SHALL route its initial load through `CommandExecutionData` on `allTabs`, `tabsCount`, and `selectedTabId`. `fetchSelectedTabId()` is a separate repository call. Concurrent callers SHALL await the in-flight `.inProgress` task for the field they requested. The service's public command API (`sendCommand`) and observer/subject notifications SHALL remain unchanged.

`TabsDataService` SHALL pre-seed `selectedTabId` as `.finished(.success(defaultSelectedTabId))` in `init` so the UI has instant selected-tab data and does not wait for the repository. It SHALL then start `fetchSelectedTabId()` by moving `selectedTabId` to `.inProgress` (the pre-seed is a UI placeholder, not a repository cache hit). On success, store `.finished(.success(realId))`. On failure, restore `.finished(.success(defaultSelectedTabId))` — the same initial value. Selected-id load failure MUST NOT fail UI loading and MUST NOT prevent the app from functioning. The in-flight task SHALL complete with that fallback id so coalesced waiters also receive the default instead of an error.

`allTabs` / `tabsCount` SHALL NOT use this fallback: their repository failure stays `.finished(.failure)` and is retryable.

#### Scenario: Initial allTabs load is single-flight
- **WHEN** `TabsDataService` performs its initial tabs fetch while another caller requests tabs concurrently
- **THEN** the repository's tab-fetching is invoked once, `allTabs` is `.inProgress` during that call, and both callers receive the same tabs array

#### Scenario: Selected tab id is pre-seeded for instant UI
- **WHEN** `TabsDataService` finishes `init` storage setup before `fetchSelectedTabId()` completes
- **THEN** `selectedTabId` is `.finished(.success(defaultSelectedTabId))` so the UI can render without waiting

#### Scenario: Initial selectedTabId load is single-flight
- **WHEN** `TabsDataService` performs `fetchSelectedTabId()` while another caller requests the selected tab id concurrently
- **THEN** that repository call is invoked once, `selectedTabId` is `.inProgress` during that call, and waiters share that task

#### Scenario: Selected tab id failure falls back to the pre-seeded default
- **WHEN** `fetchAllTabs()` succeeds and `fetchSelectedTabId()` fails
- **THEN** `allTabs` is `.finished(.success)`, `selectedTabId` is `.finished(.success(defaultSelectedTabId))` (not `.failure`), and the UI continues to function

#### Scenario: Service state and observers unchanged on success
- **WHEN** the initial load completes successfully through the cache
- **THEN** `serviceData.allTabs`, `serviceData.tabsCount`, and `serviceData.selectedTabId` are populated as `.finished(.success(...))` and observer/subject notifications fire exactly as before the change

### Requirement: Mutating commands await in-progress cache
When a mutating command needs `allTabs` and/or `selectedTabId` (`handleAddTabCommand`, and likewise close / select / replace / preview handlers that guard on those fields), the system SHALL await any of those entries that are `.inProgress` (one or both) and then proceed with the `.finished(.success)` values. It MUST NOT treat `.inProgress` as a missing cache (today: `.noAnyTabs` / `.selectedNotFound`).

If an awaited `allTabs` entry finishes as `.failure`, the mutating command SHALL fail with that error rather than mutating against an empty/unknown tabs list. An awaited `selectedTabId` that fails the repository load SHALL resolve to `defaultSelectedTabId` (see initial-load fallback); the mutation MUST still proceed.

#### Scenario: Add tab waits for in-progress allTabs
- **WHEN** `handleAddTabCommand` runs while `serviceData.allTabs` is `.inProgress`
- **THEN** the handler awaits that task and, on success, adds the tab against the loaded array instead of returning `.noAnyTabs`

#### Scenario: Add tab waits for in-progress selectedTabId
- **WHEN** `handleAddTabCommand` runs while `serviceData.selectedTabId` is `.inProgress` and `allTabs` is already `.finished(.success)`
- **THEN** the handler awaits `selectedTabId` only and then adds the tab using that identifier

#### Scenario: Add tab uses default selected id after selected-id load failure
- **WHEN** `handleAddTabCommand` awaits `selectedTabId` and `fetchSelectedTabId()` failed
- **THEN** the handler proceeds with `defaultSelectedTabId` and MUST NOT fail the add because of that repository error

#### Scenario: Add tab waits for both in-progress entries
- **WHEN** `handleAddTabCommand` runs while both `allTabs` and `selectedTabId` are `.inProgress`
- **THEN** the handler awaits both tasks before mutating

### Requirement: Overlapping mutations serialize through one shared lock
The system SHALL serialize every mutating command that writes `allTabs` and/or `selectedTabId` through **one** shared `CommandExecutionData` stored on `TabsDataService` (not on per-command `ServiceData` fields). If that shared entry is `.inProgress`, a later mutation MUST await it, then start its **own** work against the updated cache. Distinct commands MUST NOT share one task or one result.

The system MUST NOT use `tabAdded`, `tabClosed`, `tabSelected`, or other per-command fields as separate locks. Those fields SHALL remain last-write command results; `sendCommand` still returns the snapshot for that invocation.

The system MUST NOT introduce a pending-tabs queue type. `TabsDataService` is an actor, which serializes access between suspension points, but handlers await the repository before writing `allTabs` / `selectedTabId`, and actors are reentrant at `await`. The shared lock closes that window for add, close, select, replace, and preview alike.

#### Scenario: Two rapid add-tab taps add two tabs
- **WHEN** the user requests two `addTab` commands while the shared mutation lock is `.inProgress`
- **THEN** the second command waits for the first to finish, then adds a second tab; `allTabs` contains both tabs and neither add is dropped

#### Scenario: Second add does not reuse the first add’s result
- **WHEN** a second `addTab` arrives while the shared mutation lock is `.inProgress`
- **THEN** after awaiting, the second command runs its own repository add and its returned `ServiceData.tabAdded` is that second add’s result, not the first add’s index

#### Scenario: Add and close share the same lock
- **WHEN** `closeTab` (or select / replace) runs while an `addTab` holds the shared mutation lock
- **THEN** close waits for the add to finish, then mutates the updated `allTabs`; it MUST NOT read the pre-add array

#### Scenario: Per-command fields are not locks
- **WHEN** an `addTab` is in flight
- **THEN** serialization is the shared `CommandExecutionData` on `TabsDataService`, not `.inProgress` on `serviceData.tabAdded`

#### Scenario: No pending-tabs queue type
- **WHEN** overlapping mutations are serialized
- **THEN** serialization is wait-then-claim on the shared `.inProgress` entry, not a separate queue of `Tab` values
