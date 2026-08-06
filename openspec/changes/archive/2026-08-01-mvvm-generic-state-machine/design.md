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

### D2: `ViewModelStateMachine` as GoF Context + Strategy

**Choice:** `@MainActor` generic `ViewModelStateMachine` owns current state and a `StateTransitioning` strategy (Strategy pattern). `BaseViewModel` holds the machine privately and publishes state after successful transitions (Template Method for subclasses that only override `context`).

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

### D3: Closure adapter for simple VMs; handler objects for SearchBar (GoF State)

**Choice:** Ship:
1. `ClosureStateTransitioning` — wrap `(S, A, C?) async throws -> S` for enum/struct VMs
2. For SearchBar (and similar class hierarchies): **one handler object per state subclass** implementing the transition behavior (canonical GoF State pattern). The machine’s strategy dispatches to the handler bound to the current state instance; handlers are not part of `ViewModelState`

**Why:** Preserves mode-local behavior (view vs search) without a central `type(of:)` switch, and keeps `ViewModelState` as data-only while still using classic State polymorphism via handlers.

**Alternatives rejected:**
- Single strategy with `switch` on dynamic type — less extensible, not canonical State
- Free functions only — weaker encapsulation than handler objects per subclass

### D4: Errors for illegal transitions stay throwing

**Choice:** Illegal action/state pairs continue to `throw` (existing domain errors). Machine does not silently no-op unless a specific strategy chooses to.

**Why:** Matches current CottonViewModels behavior and keeps tests assertive.

### D5: Testability via package/test hooks; machine not public on BaseViewModel

**Choice:**
- Test strategies and machines without UI
- `BaseViewModel` MUST NOT expose the state machine as a public API
- Injection / observation of the machine or strategy is available only via package-visible or test hooks (e.g. `internal` initializer, `@_spi`, or test-only subclass helpers)
- Prefer Swift Testing (`@Test`) per AGENTS.md

**Why:** Keeps the production VM surface small (`state`, `sendAction`, `context`) while still allowing unit tests to substitute a fake strategy.

### D6: Leave `StateMachineV2` alone for now

**Choice:** Do not build on V2. Optionally mark deprecated later; deletion is a follow-up.

**Why:** Different model; risk of confusion if “extended” into something incompatible.

### D7: WebViewModel migration redesigns actions as fully async first

**Choice:** When adapting WebViewModel, redesign its action/transition path to be fully async before (or as the first step of) plugging into `ViewModelStateMachine`. Do not wrap the existing sync `Actionable.transition` in a thin async façade as the end state.

**Why:** Aligns WebView with the kit’s async/throws model and avoids carrying sync transition debt into the new machine.

## Risks / Trade-offs

- **[BREAKING API]** Removing `transitionOn` from `ViewModelState` breaks all conformers → Mitigate with staged migration: kit + adapters first, then update each CottonViewModels state in the same PR/series; compile failures guide the checklist.
- **[SearchBar polymorphism]** Moving overrides into per-subclass handlers adds types → Mitigate by 1:1 mapping from current `SearchBarInViewMode` / `SearchBarInSearchMode` `transitionOn` bodies into dedicated handlers.
- **[WebViewModel complexity]** Full async action redesign is larger than a façade → Mitigate by phasing: redesign actions/transitions async first, then adopt `BaseViewModel` + machine; not blocking kit landing for existing adopters.
- **[Published state sync]** Dual sources of truth (machine vs `@Published`) → Mitigate: machine is source of truth; BaseViewModel assigns published state only from machine after success; machine stays private.
- **[Over-abstraction]** Too many protocols → Mitigate: start with `ViewModelStateMachine` + `StateTransitioning` + closure adapter + SearchBar handlers; add more only when a CottonViewModels adopter needs it.

## Migration Plan

1. **Kit core**: Slim `ViewModelState`; add `StateTransitioning` + `ViewModelStateMachine`; update `BaseViewModel` / `ViewModelInterface` defaults; keep machine private with package/test hooks only.
2. **Migrate kit adopters**: BrowserToolbar, AllTabs, TabsPreviews via closure/strategy; SearchBar via per-subclass handler objects; fix tests.
3. **Kit tests**: Machine, illegal transitions, async context, BaseViewModel sendAction via package/test hooks and fake strategy.
4. **Phased adopters** (separate tasks/PRs as needed): TabViewModel, SearchSuggestions, TopSites; then WebViewModel — **async action redesign first**, then machine adoption.
5. **Rollback**: Revert kit PR if adopters not updated together; keep V2 untouched as unrelated.

## Resolved decisions (former open questions)

- **Public type name:** `ViewModelStateMachine` (not `StateMachine`).
- **Machine visibility:** `BaseViewModel` does not expose the machine publicly; only package/test hooks.
- **SearchBar:** Prefer handler objects per subclass (canonical State pattern), not a central dynamic-type switch.
- **WebViewModel:** Redesign actions to be fully async first; do not settle on a sync-in-async wrapper.

## Open Questions

- None.
