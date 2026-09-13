## 1. CommandExecutionData as cache entry

- [ ] 1.1 Do **not** add `CacheEntry` / `TabsCacheEntry`; use existing `CommandExecutionData` (`.inProgress` / `.finished`) as the cache entry
- [ ] 1.2 Add the load/coalesce helper as an extension of `CommandExecutionData` in `GenericServiceKit`: `.inProgress` awaits and returns that result; `.notStarted` / `.finished(.failure)` start a new load; `.finished(.success)` returns the cached value
- [ ] 1.3 Add a mutation wait-then-start helper **local to `TabsDataService`** that operates on the shared mutation lock (await `.inProgress` if present, then start a **new** task)
- [ ] 1.4 On success promote to `.finished(.success)`; on failure store `.finished(.failure)` (never leave a completed failed task in `.inProgress`)

## 2. TabsDataService integration

- [ ] 2.1 Use existing `serviceData.allTabs`, `serviceData.tabsCount`, and `serviceData.selectedTabId` as separate cache entries; put `allTabs` / `tabsCount` in `.inProgress` for `fetchAllTabs()` and `selectedTabId` in `.inProgress` for `fetchSelectedTabId()` (D8)
- [ ] 2.2 Route those repository reads through the GenericServiceKit coalesce helper; **keep** pre-seeding `selectedTabId` as `.finished(defaultSelectedTabId)` in `init`; still move it to `.inProgress` for `fetchSelectedTabId()` (placeholder is not a cache hit); on failure restore `.finished(.success(defaultSelectedTabId))`; preserve observer/subject notifications on successful completion
- [ ] 2.3 Verify the `init` load path (including the empty-tabs → add default tab branch) still works through `.inProgress` and the unit-testing `print` vs `fatalError` behavior is preserved
- [ ] 2.4 In `handleAddTabCommand` (and other handlers that guard on `allTabs` / `selectedTabId`), await whichever of those entries is `.inProgress` instead of failing with `.noAnyTabs` / `.selectedNotFound`
- [ ] 2.5 Add one shared mutation `CommandExecutionData` on `TabsDataService` (not `tabAdded` / `tabClosed` / …). Wait-then-claim before repository `await`s that write `allTabs` / `selectedTabId`. Do not coalesce two commands onto one task and do not add a pending-tabs queue
- [ ] 2.6 Route add, close, select, replace, and preview through that shared lock so they cannot interleave; keep per-command `ServiceData` fields as last-write results only

## 3. Tests

- [ ] 3.1 Add Swift Testing unit tests in `GenericServiceKitTests` for the `CommandExecutionData` coalesce helper: cold-load start from `.notStarted` (exactly one load task created and stored as `.inProgress`)
- [ ] 3.2 Add concurrency tests in `GenericServiceKitTests`: multiple callers while `.inProgress` share one task and receive identical results
- [ ] 3.3 Add tests in `GenericServiceKitTests`: cached read after `.finished(.success)` does not re-invoke load; `.finished(.failure)` lets a subsequent call retry fresh
- [ ] 3.4 Add tests: `TabsDataService` initial `allTabs` load is single-flight (repository fetch invoked once under concurrent callers), and observer notifications are unchanged on success
- [ ] 3.5 Add tests: `selectedTabId` is pre-seeded with `defaultSelectedTabId`, then single-flight via `fetchSelectedTabId()`; if that call fails while tabs succeed, `selectedTabId` is `.finished(.success(defaultSelectedTabId))` (not `.failure`) and the UI/app can still function
- [ ] 3.6 Add tests: `handleAddTabCommand` waits when `allTabs` and/or `selectedTabId` is `.inProgress`, then adds against the loaded values
- [ ] 3.7 Add tests: two overlapping `addTab` commands serialize through the shared lock (two repository adds, both tabs present in `allTabs`); the second result is not the first add’s index
- [ ] 3.8 Add tests: `closeTab` (or select) while `addTab` holds the shared lock waits, then mutates the post-add `allTabs`
- [ ] 3.9 Run the full domain test suite (`CottonUseCasesTests`, `GenericServiceKitTests`, new cache tests) and fix any regressions

## 4. Verification

- [ ] 4.1 Run SwiftLint on changed files; fix any violations
- [ ] 4.2 Manually smoke-test app start (initial tabs load through `.inProgress` → `.finished`) and normal add/close/select flows in the app
