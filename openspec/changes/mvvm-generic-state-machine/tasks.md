## 1. ViewModelKit core APIs

- [ ] 1.1 Slim `ViewModelState` by removing `transitionOn` methods and the default completion-based extension
- [ ] 1.2 Add `StateTransitioning` protocol for `(state, action, context?) async throws -> state`
- [ ] 1.3 Add `ViewModelStateMachine` that owns current state, applies the strategy, and leaves state unchanged on throw
- [ ] 1.4 Add a closure-based `StateTransitioning` adapter for relocating existing transition bodies
- [ ] 1.5 Update `BaseViewModel` to own/use the machine privately and publish state after successful `sendAction` (no public machine API)
- [ ] 1.6 Add package/test-only hooks to inject or substitute the transition strategy for unit tests
- [ ] 1.7 Align `ViewModelInterface` default `sendAction` implementations with the machine-backed path (no direct `state.transitionOn`)

## 2. Kit unit tests (Swift Testing)

- [ ] 2.1 Add ViewModelKitTests covering successful async transitions and failure leaving state unchanged
- [ ] 2.2 Add tests for closure strategy and a custom strategy type
- [ ] 2.3 Add BaseViewModel tests using package/test hooks with a fake strategy for success and error paths
- [ ] 2.4 Ensure new tests use Swift Testing (`@Test`) rather than new XCTest cases

## 3. Migrate existing kit-based CottonViewModels

- [ ] 3.1 Migrate `AllTabsState` / `AllTabsViewModel` transitions into a strategy (remove protocol `transitionOn`)
- [ ] 3.2 Migrate `BrowserToolbarState` / `BrowserToolbarViewModel` transitions into a strategy
- [ ] 3.3 Migrate `TabsPreviewState` / `TabsPreviewsViewModel` transitions into a strategy
- [ ] 3.4 Migrate `SearchBarState` hierarchy into **handler objects per subclass** (`InViewMode` / `InSearchMode`) for canonical GoF State; remove `ViewModelState.transitionOn`
- [ ] 3.5 Update CottonViewModelsTests affected by the migration; add focused illegal-action / happy-path transition tests where missing

## 4. Adoption readiness for remaining view models

- [ ] 4.1 Document adaptation checklist for non-kit VMs (Tab, SearchSuggestions, TopSites, WebView) referencing `BaseViewModel` + machine
- [ ] 4.2 Spike or stub the smallest remaining adopter (prefer Tab or TopSites) onto `BaseViewModel` + machine if low-risk; otherwise leave explicit follow-up tasks in code comments/docs only if needed for compile clarity
- [ ] 4.3 Note WebViewModel follow-up: redesign actions to be fully async first, then adopt the machine (no sync-in-async façade as the end state)
- [ ] 4.4 Confirm `StateMachineV2` / `ViewModelV2` remain unused by production adopters (no new dependencies on V2)

## 5. Verification

- [ ] 5.1 Build ViewModelKit and CottonViewModels targets successfully
- [ ] 5.2 Run ViewModelKitTests and CottonViewModelsTests; fix regressions
- [ ] 5.3 Spot-check that UI call sites still use `sendAction` / published `state` without needing transition APIs on state types
