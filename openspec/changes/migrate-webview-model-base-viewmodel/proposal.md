## Why

`WebViewModelImpl` still owns an ad-hoc state machine (`WebViewModelState` + sync `Actionable.transition` + `updateState` / `onStateChange` chaining) instead of ViewModelKit’s `BaseViewModel` + `ViewModelStateMachine`. That blocks the ADOPTION checklist for the largest remaining CottonViewModels type and keeps transition logic hard to unit-test apart from side effects. The kit APIs are ready; WebViewModel is the next adopter called out in the follow-up comments and ADOPTION notes.

## What Changes

- Migrate `WebViewModelImpl` to subclass `BaseViewModel` (via typealias) driven by `ViewModelStateMachine` and a dedicated `StateTransitioning` strategy.
- Redesign `WebViewAction` transitions to be **fully async** through `StateTransitioning` — do **not** wrap the existing sync `Actionable.transition` as the long-term strategy body.
- Make `WebViewModelState` / `WebViewAction` conform to `ViewModelState` / `ViewModelAction`; remove the local `Actionable` transition ownership from the state type.
- Introduce a `StateContext` (+ proxy) so DNS, DoH, plugins, tab replace, and loading-command emissions are reachable from transitions without exposing the VM type to the strategy.
- **BREAKING (consumers):** Update UIKit/SwiftUI and other call sites to drive the view model via kit `sendAction(_:)` (e.g. `.loadSite`, `.resetToSite`) instead of the old convenience methods (`load`, `reset`, `reload`, `goBack`, `goForward`, `finishLoading`, `setJavaScript`, `setDoH`, …).
- Expose kit `state` / `statePublisher` on the public `WebViewModel` surface as the primary observation API.
- Mark `webPageState` / `webPageStatePublisher` as **legacy**; future consumers MUST observe `statePublisher` only (legacy channel kept temporarily for migration).
- Update CottonViewModelsTests fixtures and WebViewModel tests for `sendAction` / strategy isolation (Swift Testing).
- Update ADOPTION.md to mark WebViewModel as adopted (or remove the WebView-specific blocker note).

## Capabilities

### New Capabilities
- `webview-model-kit-adoption`: WebViewModel adopts `BaseViewModel` + `ViewModelStateMachine` with async `StateTransitioning`, a state context for side effects, consumer migration to `sendAction` + `statePublisher`, legacy `webPageState` APIs, and testable transitions.

### Modified Capabilities
- `viewmodel-testability`: Extend adoption/testability expectations so complex multi-step view models (WebViewModel-style) can unit-test the strategy and context-backed async transitions in isolation.

## Impact

- **CottonViewModels / WebViewModel**: `WebViewModelImpl.swift`, `WebViewModel.swift` protocol, `WebViewModelState.swift`, `WebViewModelState+Actionable.swift`, `WebViewAction.swift`, related context/protocol files; remove or retire sync `Actionable` usage for this VM.
- **ViewModelKit**: No required API changes expected; reuse `BaseViewModel`, `ViewModelStateMachine`, `StateTransitioning` / `ClosureStateTransitioning`.
- **UI / app consumers**: Presentation, coordinators, browser views, factories, and any code calling `load`/`reset`/… MUST switch to `sendAction` and prefer `statePublisher` over legacy `webPageStatePublisher`.
- **Tests**: `CottonViewModelsTests` WebViewVM suite + fixtures; possibly new strategy-focused tests.
- **Out of scope**: `TabViewModel`, `SearchSuggestionsViewModel`, `TopSitesViewModel`; `StateMachineV2` / `ViewModelV2`; immediate deletion of legacy `webPageState` (deprecate first).
