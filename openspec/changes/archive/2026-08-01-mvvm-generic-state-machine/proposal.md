## Why

`ViewModelState` currently owns transition logic (`transitionOn`), which mixes immutable/UI state with orchestration. That makes transitions hard to reuse, extend, and unit-test independently of each state type. `StateMachineV2` is too minimal (sync dictionary of closures, no context/async/errors) and cannot cover existing CottonViewModels cases (async use cases, optional context, class hierarchies, invalid-action errors).

## What Changes

- Introduce a generic **State Machine** in ViewModelKit that owns action → next-state transitions (async/throws, optional `StateContext`).
- **BREAKING**: Slim `ViewModelState` to pure state concerns (`createInitial`, associated types, equality/sendability). Remove `transitionOn` from the protocol.
- Wire `BaseViewModel` / `ViewModelInterface.sendAction` through the state machine instead of calling `state.transitionOn`.
- Support GoF-inspired patterns where they fit modern Swift: State (per-state behavior), Strategy/Command for transition handlers, Template Method via `BaseViewModel`.
- Provide a migration path so every CottonViewModels view model can adopt `BaseViewModel` + the new machine (including ones that currently use ad-hoc state like WebViewModel).
- Add ViewModelKit unit-test APIs/fixtures so state transitions and view models are easy to cover with Swift Testing.
- Deprecate or leave `StateMachineV2` / `ViewModelV2` as a non-goal for production migration (do not extend it as the main design).

## Capabilities

### New Capabilities
- `viewmodel-state`: Pure `ViewModelState` contract without transition APIs; keeps Action/Context/BaseState associations and initial-state factory.
- `viewmodel-state-machine`: Generic async state machine that performs transitions, validates/rejects illegal actions, updates current state, and integrates with `BaseViewModel`.
- `viewmodel-testability`: Testable hooks and patterns for unit-testing transitions and BaseViewModel-backed view models in isolation.

### Modified Capabilities

- (none — no existing specs under `openspec/specs/`)

## Impact

- **ViewModelKit**: `ViewModelState.swift`, `BaseViewModel.swift`, `ViewModelInterface.swift`; new `StateMachine` type(s); optional test helpers.
- **CottonViewModels** (adopters of `ViewModelState` today): SearchBar, BrowserToolbar, AllTabs, TabsPreviews — move `transitionOn` implementations into state-machine transition definitions (or state-handler objects).
- **CottonViewModels** (not yet on `BaseViewModel`): WebViewModel, TabViewModel, SearchSuggestionsViewModel, TopSitesViewModel, BaseList — design must allow gradual adaptation without forcing a big-bang rewrite in one PR.
- **Tests**: ViewModelKitTests + CottonViewModelsTests need updates for the new transition ownership model.
- **Consumers** (UIKit/SwiftUI): Public `sendAction` / `@Published state` surface should remain; transition call sites on states break and need migration.
