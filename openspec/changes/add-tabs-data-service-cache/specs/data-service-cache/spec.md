## ADDED Requirements

### Requirement: CommandExecutionData is the cache entry
The system SHALL use existing `CommandExecutionData<Input, Output, E>` as the in-memory cache entry for a single async load. It MUST NOT introduce a separate `CacheEntry`, `TabsCacheEntry`, or equivalent type whose only purpose is to model in-progress vs ready states.

Cache semantics map onto existing cases:
- `.inProgress(Task<Output, E>)` — a load is currently executing; the task is the shared handle to its result.
- `.finished(output: .success(value))` — a value has been loaded and is cached (the ready state).
- `.finished(output: .failure(error))` — the load failed; the failure is recorded so callers observe the error and a later request can retry.

`CommandExecutionData` SHALL remain `Sendable`.

#### Scenario: In-progress state holds shared task
- **WHEN** a load has been started and not yet finished
- **THEN** the cache entry is `.inProgress` holding the `Task<Output, E>` that any caller can await to obtain the same result

#### Scenario: Finished success is the ready state
- **WHEN** a load has completed successfully
- **THEN** the cache entry is `.finished(output: .success(value))` and exposes the loaded `Output` without re-executing any load

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
`TabsDataService` SHALL route its initial tabs load through `CommandExecutionData` (already used as `AllTabsData` / `SelectedTabData` on `TabsServiceData`) so that the first consumer initiates the repository load and any subsequent concurrent callers await the same `.inProgress` task. The service's public command API (`sendCommand`) and observer/subject notifications SHALL remain unchanged.

#### Scenario: Initial load is single-flight in TabsDataService
- **WHEN** `TabsDataService` performs its initial load while another caller requests tabs concurrently
- **THEN** the repository's tab-fetching is invoked once and both callers receive the same tabs array

#### Scenario: Service state and observers unchanged
- **WHEN** the initial load completes through the cache
- **THEN** `serviceData.allTabs`, `serviceData.tabsCount`, and `serviceData.selectedTabId` are populated as `.finished(.success(...))` and observer/subject notifications fire exactly as before the change
