# Adapting a CottonViewModels type to `BaseViewModel` + `ViewModelStateMachine`

Use this checklist for view models that are not yet on ViewModelKit (`TopSitesViewModel`, etc.).

## Steps

1. **Define pure state** conforming to `ViewModelState` (`Action`, `Context`, `BaseState`, `createInitial`). Do **not** put `transitionOn` on the state.
2. **Define actions** as `ViewModelAction` (prefer enums).
3. **Define `StateContext`** for use-case / side-effect access without exposing the VM type.
4. **Implement transitions** via `StateTransitioning`:
   - Enum/struct VMs: `ClosureStateTransitioning` or a dedicated `*StateTransitioning` struct.
   - Class hierarchies (SearchBar-style): **handler object per subclass** + a thin strategy that calls `state.modeHandler`.
5. **Typealias** the public VM to `BaseViewModel<State, Action, Context>`.
6. **Subclass** and call `super.init(transitioning: ...)`. Override `context` to return a proxy.
7. **Drive UI** only through `sendAction` / published `state` (no transition APIs on state types).
8. **Unit-test** the strategy/handlers in isolation (Swift Testing); use package/test hooks on `BaseViewModel` when testing `sendAction`.

## Adopted

- **WebViewModel** — uses `BaseViewModel` + `ViewModelStateMachine` + `WebViewStateTransitioning`; consumers drive via `sendAction` and observe `statePublisher` only.
- **SearchSuggestionsViewModel** — uses `BaseViewModel` + `ViewModelStateMachine` + `SearchSuggestionsStateTransitioning`; progressive fetch via sequenced `.loadKnownDomains` / `.loadSuggestions` (`fetchSuggestions` helper only sequences `sendAction`).
- **TabViewModel** — uses `BaseViewModel` + `ViewModelStateMachine` + `TabStateTransitioning`; `TabsObserver` / Observation adapters only `sendAction`; thin `load` / `close` / `activate` helpers only call `sendAction`.

## Do not use

`StateMachineV2` / `ViewModelV2` — reserved / experimental; production adopters use `ViewModelStateMachine`.
