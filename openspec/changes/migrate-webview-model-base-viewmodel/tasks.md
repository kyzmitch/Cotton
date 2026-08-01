## 1. Kit conformances for WebView types

- [ ] 1.1 Make `WebViewAction` conform to `ViewModelAction` with a manual representative `allCases` list
- [ ] 1.2 Refactor `WebViewModelState` to `ViewModelState` (context type parameter, `Action`/`Context`/`BaseState`, `createInitial` → `.pendingLoad`); keep existing accessors/`Equatable`
- [ ] 1.3 Add `WebViewStateContext` protocol + `WebViewStateContextProxy` for loading-action emission, DoH/plugins/DNS/tab side effects

## 2. Async transition strategy

- [ ] 2.1 Add `WebViewStateTransitioning` implementing `StateTransitioning` with a genuine `async throws` graph (port legal cases from `WebViewModelState+Actionable`, await context where DoH/DNS/plugins require it)
- [ ] 2.2 Ensure illegal pairs throw existing domain errors and do not mutate state when driven via the machine
- [ ] 2.3 Decide which auto-chain hops stay as successive machine updates vs internalized awaits; document choices briefly in code comments only where non-obvious

## 3. Rewire WebViewModelImpl to BaseViewModel

- [ ] 3.1 Introduce `WebViewModel`/`WebViewModelBase` typealias to `BaseViewModel<...>` and make `WebViewModelImpl` subclass it with `super.init(transitioning: WebViewStateTransitioning())`
- [ ] 3.2 Override `context` to return the proxy; implement context methods on the impl (use cases, `WebViewContext`, `webPageState` updates)
- [ ] 3.3 Map public `WebViewModel` methods (`load`, `reset`, `reload`, navigation, `finishLoading`, JS/DoH, `decidePolicy`) to `sendAction` + remaining local policy helpers; preserve dual `webPageState` channel
- [ ] 3.4 Handle optional-`Site` init: after `super.init`, establish `.initialized(site)` on published/machine state without a fake transition
- [ ] 3.5 Remove `updateState` / `onStateChange` reactor and production use of sync `Actionable.transition`; delete or empty obsolete Actionable files

## 4. Tests and adoption docs

- [ ] 4.1 Update `WebViewVMFixture` and existing WebView concurrency/DoH tests for the new initializer/`sendAction` paths
- [ ] 4.2 Add Swift Testing strategy-focused tests (legal paths, illegal action, fake-context DoH/DNS branch) per `viewmodel-testability` delta
- [ ] 4.3 Update `openspec/changes/archive/2026-08-01-mvvm-generic-state-machine/ADOPTION.md` (WebView note) to mark adoption done; remove follow-up comments on `WebViewModelImpl`
- [ ] 4.4 Run Domain / CottonViewModels-related tests and fix regressions
