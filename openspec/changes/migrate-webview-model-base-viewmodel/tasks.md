## 1. Kit conformances for WebView types

- [ ] 1.1 Make `WebViewAction` conform to `ViewModelAction` with a manual representative `allCases` list
- [ ] 1.2 Refactor `WebViewModelState` to `ViewModelState` (context type parameter, `Action`/`Context`/`BaseState`, `createInitial` → `.pendingLoad`); keep existing accessors/`Equatable`
- [ ] 1.3 Add `WebViewStateContext` protocol + `WebViewStateContextProxy` for loading-command emission, DoH/plugins/DNS/tab side effects

## 2. Async transition strategy

- [ ] 2.1 Add `WebViewStateTransitioning` implementing `StateTransitioning` with a genuine `async throws` graph (port legal cases from `WebViewModelState+Actionable`, await context where DoH/DNS/plugins require it)
- [ ] 2.2 Ensure illegal pairs throw existing domain errors and do not mutate state when driven via the machine
- [ ] 2.3 Decide which auto-chain hops stay as successive machine updates vs internalized awaits; document choices briefly in code comments only where non-obvious

## 3. Rewire WebViewModelImpl to BaseViewModel

- [ ] 3.1 Introduce `WebViewModel`/`WebViewModelBase` typealias to `BaseViewModel<...>` and make `WebViewModelImpl` subclass it with `super.init(transitioning: WebViewStateTransitioning())`
- [ ] 3.2 Override `context` to return the proxy; implement context methods on the impl (use cases, `WebViewContext`, loading-command emission / legacy dual-write)
- [ ] 3.3 Expose kit `state`, `statePublisher`, and `sendAction` on the public `WebViewModel` protocol; remove or deprecate convenience methods (`load`, `reset`, …)
- [ ] 3.4 Mark `webPageState` / `webPageStatePublisher` as legacy/deprecated; keep dual-write only as needed during cutover (`statePublisher` is primary)
- [ ] 3.5 Handle optional-`Site` init: after `super.init`, establish `.initialized(site)` on published/machine state without a fake transition
- [ ] 3.6 Remove `updateState` / `onStateChange` reactor and production use of sync `Actionable.transition`; delete or empty obsolete Actionable files

## 4. Update consumers and tests

- [ ] 4.1 Update in-repo UIKit/SwiftUI/coordinator/factory call sites to use `sendAction` instead of `load`/`reset`/`reload`/navigation/JS/DoH helpers
- [ ] 4.2 Migrate consumer observation from `webPageStatePublisher` to `statePublisher` (leave legacy API only if still dual-written)
- [ ] 4.3 Update `WebViewVMFixture` and existing WebView concurrency/DoH tests for `sendAction` / `statePublisher`
- [ ] 4.4 Add Swift Testing strategy-focused tests (legal paths, illegal action, fake-context DoH/DNS branch) per `viewmodel-testability` delta
- [ ] 4.5 Update `openspec/changes/archive/2026-08-01-mvvm-generic-state-machine/ADOPTION.md` (WebView note) to mark adoption done; remove follow-up comments on `WebViewModelImpl`
- [ ] 4.6 Run Domain / CottonViewModels-related tests and fix regressions
