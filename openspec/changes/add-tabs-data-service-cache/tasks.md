## 1. CommandExecutionData as cache entry

- [ ] 1.1 Do **not** add `CacheEntry` / `TabsCacheEntry`; use existing `CommandExecutionData` (`.inProgress` / `.finished`) as the cache entry
- [ ] 1.2 Add an awaiting / start-or-join helper as an extension of `CommandExecutionData` (or a file-local extension if only `TabsDataService` needs it): `.notStarted` starts a task and stores `.inProgress`; `.inProgress` awaits the existing task; `.finished(.success)` returns the value; `.finished(.failure)` starts a fresh load
- [ ] 1.3 On success promote to `.finished(.success)`; on failure store `.finished(.failure)` (never leave a completed failed task in `.inProgress`)

## 2. TabsDataService integration

- [ ] 2.1 Use existing `serviceData.allTabs` / `serviceData.selectedTabId` (`CommandExecutionData`) as the cache for the initial load (tabs array + selected tab id combined, per design D5 / open question)
- [ ] 2.2 Route `fetchTabs()` repository reads through `.inProgress`, preserving all `serviceData` writes (`allTabs`, `tabsCount`, `selectedTabId` as `.finished(.success)`) and observer/subject notifications exactly as before
- [ ] 2.3 Verify the `init` load path (including the empty-tabs → add default tab branch) still works through `.inProgress` and the unit-testing `print` vs `fatalError` behavior is preserved

## 3. Tests

- [ ] 3.1 Add Swift Testing unit tests for cold-load start from `.notStarted` (exactly one load task created and stored as `.inProgress`)
- [ ] 3.2 Add concurrency tests: multiple callers while `.inProgress` share one task and receive identical results
- [ ] 3.3 Add tests: cached read after `.finished(.success)` does not re-invoke load; `.finished(.failure)` lets a subsequent call retry fresh
- [ ] 3.4 Add tests: `TabsDataService` initial load is single-flight (repository fetch invoked once under concurrent callers), and observer notifications are unchanged
- [ ] 3.5 Run the full domain test suite (`CottonUseCasesTests`, `GenericServiceKitTests`, new cache tests) and fix any regressions

## 4. Verification

- [ ] 4.1 Run SwiftLint on changed files; fix any violations
- [ ] 4.2 Manually smoke-test app start (initial tabs load through `.inProgress` → `.finished`) and normal add/close/select flows in the app
