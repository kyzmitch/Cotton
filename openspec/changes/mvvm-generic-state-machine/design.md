## Context

ViewModelKit already provides `BaseViewModel<S, A, C>`, `ViewModelInterface`, `ViewModelState`, `ViewModelAction`, and `StateContext`. Four CottonViewModels types already use this stack (SearchBar, BrowserToolbar, AllTabs, TabsPreviews). Transition logic lives on `ViewModelState.transitionOn`, so state values also act as the transition engine.

Existing state shapes differ:
- **Enum** (`TabsPreviewState`) — switch on action; async context calls
- **Struct** (`BrowserToolbarState`, `AllTabsState`) — mutate copy / side effects via context
- **Class hierarchy** (`SearchBarState` subclasses) — classic GoF State polymorphism via overrides
- **Ad-hoc** (`WebViewModelState` + `Actionable`) — sync transitions, not on ViewModelKit

`StateMachineV2` (sync `[Event: (State) -> State]`) cannot express async, throwing, optional context, or polymorphic class states. Platform constraint: Domain package targets iOS 15; keep `ObservableObject` / Combine rather than Observation-only APIs.

## Goals / Non-Goals

**Goals:**
- Move transition ownership into a generic ViewModelKit **state machine** used by `BaseViewModel`
- Keep `ViewModelState` as pure state (identity + `createInitial` + associated types)
- Cover all current transition styles (async/throws, context, enum/struct/class)
- Enable isolated unit tests for transitions and view-model action handling (Swift Testing)
- Allow gradual CottonViewModels adoption, including eventual WebViewModel-style VMs

**Non-Goals:**
- Rewriting every CottonViewModels type in one change (WebViewModel / Tab / Suggestions / TopSites may follow)
- Extending or promoting `StateMachineV2` / `ViewModelV2` as the production design
- Migrating to `@Observable` / Observation framework (optional future)
- Introducing third-party FSM libraries

## Decisions

### D1: Slim `ViewModelState`; transitions live on a separate strategy

**Choice:** Remove `transitionOn` from `ViewModelState`. Introduce a `StateTransitioning` (name TBD in impl) strategy that the machine invokes:

```swift
@MainActor
public protocol StateTransitioning<S: ViewModelState>: Sendable
    where S == S.BaseState {
    func transition(
        from state: S,
        on action: S.Action,
        with context: S.Context?
    ) async throws -> S
}
```

**Why:** Separates data from orchestration (SRP). Matches the user’s intent that transitions belong to the machine, not the state marker.

**Alternatives:**
- Keep `transitionOn` on state (status quo) — easy for SearchBar, but keeps mixed responsibilities
- Pure transition table keyed by `(StateID, Action)` — awkward for class hierarchies and associated values

### D2: `StateMachine` as GoF Context + Strategy

**Choice:** `@MainActor` generic machine owns current state and a `StateTransitioning` strategy (Strategy pattern). `BaseViewModel` holds the machine and publishes state after successful transitions (Template Method for subclasses that only override `context`).

```text
sendAction(action)
  → machine.send(action, context)
    → strategy.transition(from:current, on:action, with:context)
    → update current state
  → @Published state = machine.state
```

**Why:** Classic FSM Context (machine) + Strategy (transition definition) covers enum/struct via one strategy type, and class hierarchies via a strategy that dispatches to type-specific handlers (or temporary adapters).

**GoF mapping (open-source State / Strategy usage):**
- **State**: optional per-state handlers for SearchBar-like polymorphism (handlers are not part of `ViewModelState`)
- **Strategy**: pluggable `StateTransitioning`
- **Command**: actions remain discrete `ViewModelAction` values applied by the machine
- **Template Method**: `BaseViewModel.sendAction` default path; subclasses supply `context`

**Alternatives:**
- Machine with hardcoded switch — not reusable across VMs
- Only closure-based API — fine for simple VMs, weaker typing for complex SearchBar/WebView cases (still allow closure adapter)

### D3: Closure adapter + polymorphic adapter for migration

**Choice:** Ship:
1. `ClosureStateTransitioning` — wrap `(S, A, C?) async throws -> S`
2. Optional adapter that, during migration, can call existing per-type transition functions relocated off the protocol

SearchBar keeps polymorphic behavior by moving overrides into dedicated handler types or free functions selected by dynamic type — not by `ViewModelState` conformance.

**Why:** Lowest-friction path from today’s `transitionOn` implementations without forcing enum-only redesign.

### D4: Errors for illegal transitions stay throwing

**Choice:** Illegal action/state pairs continue to `throw` (existing domain errors). Machine does not silently no-op unless a specific strategy chooses to.

**Why:** Matches current CottonViewModels behavior and keeps tests assertive.

### D5: Testability first-class in ViewModelKitTests

**Choice:**
- Test strategies and machines without UI
- Allow injecting a recording/fake `StateTransitioning` into `BaseViewModel` (or a test subclass / package-visible initializer)
- Prefer Swift Testing (`@Test`) per AGENTS.md

**Why:** User requirement to cover view models with unit tests; today’s transitions are buried in state types and hard to fake.

### D6: Leave `StateMachineV2` alone for now

**Choice:** Do not build on V2. Optionally mark deprecated later; deletion is a follow-up.

**Why:** Different model; risk of confusion if “extended” into something incompatible.

## Risks / Trade-offs

- **[BREAKING API]** Removing `transitionOn` from `ViewModelState` breaks all conformers → Mitigate with staged migration: kit + adapters first, then update each CottonViewModels state in the same PR/series; compile failures guide the checklist.
- **[SearchBar polymorphism]** Class overrides today map cleanly to State pattern on the type itself → Mitigate with explicit handlers / dynamic dispatch strategy so behavior stays local to each mode.
- **[WebViewModel complexity]** Sync `Actionable` + side effects in VM differs from async kit model → Mitigate by documenting adaptation steps; full WebView migration is phased, not blocking kit landing.
- **[Published state sync]** Dual sources of truth (machine vs `@Published`) → Mitigate: machine is source of truth; BaseViewModel assigns published state only from machine after success.
- **[Over-abstraction]** Too many protocols → Mitigate: start with `StateMachine` + `StateTransitioning` + one closure adapter; add more only when a CottonViewModels adopter needs it.

## Migration Plan

1. **Kit core**: Slim `ViewModelState`; add `StateTransitioning` + `StateMachine`; update `BaseViewModel` / `ViewModelInterface` defaults.
2. **Migrate kit adopters**: SearchBar, BrowserToolbar, AllTabs, TabsPreviews — relocate transition bodies into strategies/handlers; fix tests.
3. **Kit tests**: Machine, illegal transitions, async context, BaseViewModel sendAction, injectable fake strategy.
4. **Phased adopters** (separate tasks/PRs as needed): TabViewModel, SearchSuggestions, TopSites, then WebViewModel (largest).
5. **Rollback**: Revert kit PR if adopters not updated together; keep V2 untouched as unrelated.

## Open Questions

- Exact public name: `StateMachine` vs `ViewModelStateMachine` (prefer `ViewModelStateMachine` to avoid clashing with unrelated FSM types).
- Should `BaseViewModel` expose the machine publicly for advanced tests, or only via package/test hooks?
- For SearchBar, prefer handler objects per subclass vs one strategy with `switch` on `type(of:)`?
- When migrating WebViewModel, keep sync transitions inside an async strategy wrapper, or redesign actions to be fully async first?
