## 1. CacheEntry type

- [ ] 1.1 Create `CacheEntry<Value>` generic enum (`Sendable`, `Value: Sendable`) in `CottonTabs` with `.inProgress(Task<Value, Error>)` and `.ready(Value)` cases, documented per issue #97
- [ ] 1.2 Add an awaiting helper on `CacheEntry` (e.g. `value()` or equivalent) that awaits the in-flight task or returns the ready value, keeping error propagation untyped
- [ ] 1.3 Add a small single-flight load helper (start-or-join) usable by actor hosts: creates the task when entry is `nil`, stores `.inProgress`, awaits, promotes to `.ready` on success, clears to `nil` on failure

## 2. TabsDataService integration

- [ ] 2.1 Add private cache entry storage to `TabsDataService` for the initial load (tabs array + selected tab id combined, per design D5 / open question)
- [ ] 2.2 Route `fetchTabs()` repository reads through the cache entry, preserving all `serviceData` writes (`allTabs`, `tabsCount`, `selectedTabId`) and observer/subject notifications exactly as before
- [ ] 2.3 Verify the `init` load path (including the empty-tabs → add default tab branch) still works through the cache and the unit-testing `print` vs `fatalError` behavior is preserved

## 3. Tests

- [ ] 3.1 Add Swift Testing unit tests for `CacheEntry` cold-load start (exactly one load task created)
- [ ] 3.2 Add concurrency tests: multiple callers while `.inProgress` share one task and receive identical results
- [ ] 3.3 Add tests: cached read after success does not re-invoke load; failure clears entry so a subsequent call retries fresh
- [ ] 3.4 Add tests: `TabsDataService` initial load is single-flight (repository fetch invoked once under concurrent callers), and `serviceData` / observer notifications are unchanged
- [ ] 3.5 Run the full domain test suite (`CottonUseCasesTests`, `GenericServiceKitTests`, new cache tests) and fix any regressions

## 4. Verification

- [ ] 4.1 Run SwiftLint on changed files; fix any violations
- [ ] 4.2 Manually smoke-test app start (initial tabs load through the cache) and normal add/close/select flows in the app
