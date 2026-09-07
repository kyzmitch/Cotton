## ADDED Requirements

### Requirement: Generic cache entry states
The system SHALL provide a generic `CacheEntry<Value>` enum (with `Value: Sendable`) that models the state of a single in-memory async load with exactly two states:
- `.inProgress(Task<Value, Error>)` — a load is currently executing; the task is the shared handle to its result.
- `.ready(Value)` — a value has been loaded and is cached.

`CacheEntry` SHALL be `Sendable`.

#### Scenario: In-progress state holds shared task
- **WHEN** a load has been started and not yet finished
- **THEN** the cache entry is `.inProgress` holding the `Task<Value, Error>` that any caller can await to obtain the same result

#### Scenario: Ready state holds cached value
- **WHEN** a load has completed successfully
- **THEN** the cache entry is `.ready` and exposes the loaded `Value` without re-executing any load

### Requirement: First caller initiates load
When no cache entry exists, the system SHALL start the underlying async load by creating a `Task<Value, Error>`, store it as `.inProgress`, and await its result.

#### Scenario: Cold cache starts load
- **WHEN** the cache entry is `nil` and a load is requested
- **THEN** exactly one load task is created and stored as `.inProgress` before awaiting

### Requirement: Concurrent callers coalesce onto in-flight load
When a load is `.inProgress`, any subsequent caller MUST await the existing task's result instead of starting a new load.

#### Scenario: Concurrent first loads share one task
- **WHEN** multiple callers request the load while the entry is `.inProgress`
- **THEN** the underlying load executes exactly once and all callers receive the same result

### Requirement: Successful load is cached
When the awaited task completes successfully, the system SHALL store `.ready(value)` so subsequent callers receive the value immediately without re-loading.

#### Scenario: Cached read after success
- **WHEN** the entry is `.ready` and a load is requested
- **THEN** the cached value is returned without invoking the load closure/task again

#### Scenario: Entry promoted after await
- **WHEN** a caller awaiting an `.inProgress` task receives a successful result
- **THEN** the entry transitions to `.ready(value)`

### Requirement: Failed load clears entry for retry
When the awaited task fails, the system SHALL clear the cache entry (set it back to `nil`) so the next caller starts a fresh load instead of awaiting a failed task forever.

#### Scenario: Retry after failure
- **WHEN** a load task throws and a subsequent load is requested
- **THEN** the cache entry is `nil` (not `.inProgress` with a failed task) and a new load is started

#### Scenario: Concurrent callers observe failure
- **WHEN** multiple callers await an `.inProgress` task that ultimately fails
- **THEN** all callers receive the error and the entry is cleared for the next attempt

### Requirement: TabsDataService uses cache for initial load
`TabsDataService` SHALL route its initial tabs load through the in-memory cache entry so that the first consumer initiates the repository load and any subsequent concurrent callers await the same result. The service's public command API (`sendCommand`), `ServiceData` publishing, and observer/subject notifications SHALL remain unchanged.

#### Scenario: Initial load is single-flight in TabsDataService
- **WHEN** `TabsDataService` performs its initial load while another caller requests tabs concurrently
- **THEN** the repository's tab-fetching is invoked once and both callers receive the same tabs array

#### Scenario: Service state and observers unchanged
- **WHEN** the initial load completes through the cache
- **THEN** `serviceData.allTabs`, `serviceData.tabsCount`, and `serviceData.selectedTabId` are populated and observer/subject notifications fire exactly as before the change
