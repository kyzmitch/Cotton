## Why

`TabViewModelImpl` still owns its own `@Published` state and mutates it directly from `load`, `TabsObserver` callbacks, and favicon/select paths, instead of ViewModelKit’s `BaseViewModel` + `ViewModelStateMachine`. That leaves Tab off the ADOPTION checklist next to TopSites, duplicates patterns already standardized on SearchBar/AllTabs/WebView/SearchSuggestions, and keeps selection/favicon transition logic hard to unit-test apart from the concrete impl. The kit APIs and prior adopter playbooks are ready; Tab is a well-bounded next adopter.

## What Changes

- Migrate `TabViewModel` / `TabViewModelImpl` to a `BaseViewModel` typealias driven by `ViewModelStateMachine` and a dedicated `StateTransitioning` strategy.
- Make `TabViewState` conform to `ViewModelState` (`createInitial`, context type parameter); introduce `TabAction` as `ViewModelAction`.
- Introduce a kit `StateContext` (+ proxy) so read/close/select tab use cases, favicon resolution, and web-view removal are reachable from transitions without the strategy depending on `TabViewModelImpl`.
- Route selection, deselection, content replace, and initial load through machine actions; keep `TabsObserver` (and iOS 17 observation) as input adapters that only `sendAction`.
- **BREAKING (consumers):** Drive the view model via kit `sendAction` (e.g. `.load`, `.close`, `.activate`, `.applySelection`, `.applyReplace`). Keep thin `load` / `close` / `activate` conveniences only if needed as short-lived shims that solely call `sendAction`; prefer the `BaseViewModel` typealias used by other adopters while preserving `TabsObserver` on the impl (or a thin protocol if existentials require it).
- Update CottonViewModelsTests for `sendAction` / strategy isolation with Swift Testing.
- Update ADOPTION.md to mark Tab as adopted.

## Capabilities

### New Capabilities
- `tab-viewmodel-kit-adoption`: Tab adopts `BaseViewModel` + `ViewModelStateMachine` with async `StateTransitioning`, a state context for tab/favicon side effects, observer→action adapters, consumer migration to `sendAction` + `statePublisher`, and testable transitions.

### Modified Capabilities
- `viewmodel-testability`: Extend adopter coverage expectations so Tab-style selection/favicon/replace flows can be unit-tested via strategy/context without UI assemblies.

## Impact

- **CottonViewModels / TabViewModel**: `TabViewModel.swift`, `TabViewModelImpl.swift`, `TabViewState.swift`, `TabViewContext.swift` (and new action/context/transitioning types as needed); `ModuleVMFactory.createTabVM` return type aligns with the typealias (or thin protocol).
- **ViewModelKit**: No required API changes expected; reuse `BaseViewModel`, `ViewModelStateMachine`, `StateTransitioning`.
- **UI / app consumers**: `TabView`, `TabsViewController`, factories that call `load` / `close` / `activate` MUST switch to `sendAction` (or temporary shims).
- **Tests**: New strategy-focused Swift Testing coverage; any existing Tab VM tests updated for kit APIs.
- **Out of scope**: `TopSitesViewModel`; `StateMachineV2` / `ViewModelV2`; Observation / `@Observable` migration beyond existing iOS 17 tabs observation wiring.
