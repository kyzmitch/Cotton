## ADDED Requirements

### Requirement: Tab uses BaseViewModel and ViewModelStateMachine
`TabViewModelImpl` MUST subclass a `BaseViewModel` typealias parameterized by Tab domain state, `TabAction`, and a Tab `StateContext` proxy.

Domain state transitions MUST run only through `sendAction` → private `ViewModelStateMachine` → `StateTransitioning`. The implementation MUST NOT assign published domain state as the primary production path outside the machine (except a one-time post-`super.init` title seed matching prior init behavior, and any transient dual-write only if required during an in-PR cutover, which MUST be removed before completion).

`StateMachineV2` / `ViewModelV2` MUST NOT be used for this adoption.

The former standalone `TabViewModel` protocol (redeclaring `state` / `statePublisher` / `load` / `close` / `activate`) MUST be replaced by the `BaseViewModel` typealias (same adoption shape as AllTabs / SearchSuggestions). `TabsObserver` MAY remain on the concrete impl as an input adapter.

#### Scenario: load goes through the machine
- **WHEN** a consumer drives tab load via `sendAction` (or a helper that only calls `sendAction`)
- **THEN** published kit `state` / `statePublisher` advances only as a result of state-machine transitions

#### Scenario: Illegal action preserves state
- **WHEN** an action is invalid for the current `TabViewState`
- **THEN** the transition strategy throws a domain error and published domain state remains unchanged

### Requirement: Async Tab transition strategy
CottonViewModels MUST provide a dedicated `StateTransitioning` type for Tab domain state whose `transition(from:on:with:)` is `async throws` and MAY await the Tab `StateContext` for selected-tab identity, favicon resolution, close, and activate side effects.

#### Scenario: Load awaits selection and favicon
- **WHEN** a `.load` (or equivalent) action is applied
- **THEN** the strategy awaits context-backed selection and favicon resolution and returns selected or deselected state with title and favicon

#### Scenario: Selection chrome without favicon reload
- **WHEN** an `.applySelection` (or equivalent) action is applied
- **THEN** the strategy returns the same title/favicon with updated selected/deselected chrome

#### Scenario: Replace updates title and favicon
- **WHEN** an `.applyReplace` (or equivalent) action is applied for this tab
- **THEN** the strategy returns state with the new title and favicon while preserving selection chrome semantics consistent with prior behavior

#### Scenario: Strategy without UI assembly
- **WHEN** a unit test invokes the Tab transition strategy with a fake context
- **THEN** it can assert the next state or thrown error without constructing UIKit/SwiftUI views

### Requirement: Tab state and action kit conformances
`TabViewState` MUST conform to `ViewModelState` (including `createInitial`, associated `Action` / `Context` / `BaseState`, and `Equatable`).

`createInitial` MUST return an empty deselected chrome state (no title/favicon).

`TabAction` MUST conform to `ViewModelAction`, including a manual `allCases` list suitable for associated-value cases.

Existing presentation helpers on the state (`selected()`, `deSelected()`, `withNew`, static selected/deselected factories) MUST remain available to UI consumers (adjusted for the context generic as needed).

`ImageSource` MUST be `Equatable` so `TabViewState` can satisfy `ViewModelState`.

#### Scenario: Initial state before seed
- **WHEN** a Tab view model is constructed via `BaseViewModel` init alone
- **THEN** kit domain state from `createInitial` is empty deselected chrome

#### Scenario: Title seed after init
- **WHEN** `TabViewModelImpl` finishes initialization with a concrete tab
- **THEN** published state shows that tab’s title in deselected chrome before async load completes (same UX as today’s init)

### Requirement: TabsObserver and Observation are sendAction adapters
`TabsObserver` methods on the Tab impl (and iOS 17 Observation handlers that forward into them) MUST only drive domain updates via `sendAction`. They MUST NOT assign published domain state directly.

#### Scenario: Select routes through sendAction
- **WHEN** `tabDidSelect` runs for the observed tabs change
- **THEN** selection chrome updates only after a successful machine transition for the selection action

#### Scenario: Replace routes through sendAction
- **WHEN** `tabDidReplace` runs for this tab’s id
- **THEN** title/favicon updates only after a successful machine transition for the replace action

### Requirement: StateContext for Tab side effects
A Tab `StateContext` protocol (plus proxy used as the `BaseViewModel` context type) MUST expose the side-effect operations the strategy needs without the strategy depending on `TabViewModelImpl` directly.

Those operations MUST cover at least: resolving whether the tab is selected, resolving favicon `ImageSource?`, closing the tab (including web-view removal as today), and activating/selecting the tab.

`TabViewModelContext` MAY remain the app/feature-flags input to the impl initializer; it is not required to be the kit `StateContext` type itself.

#### Scenario: Proxy does not leak into strategy generics beyond Context
- **WHEN** the transition strategy is typed over `State.Context`
- **THEN** it compiles and runs against the proxy/fake context without importing UI layers

### Requirement: Consumers use sendAction and statePublisher
In-repo consumers MUST drive Tab via kit `sendAction` (and/or thin helpers that only wrap `sendAction`) instead of a protocol-only `load` / `close` / `activate` that mutates state directly.

Factories and stored properties that previously used the standalone `TabViewModel` protocol MUST use the `TabViewModel` typealias (concrete `BaseViewModel` subclass type), consistent with other kit adopters.

#### Scenario: TabView uses kit APIs
- **WHEN** `TabView` loads, closes, or activates a tab
- **THEN** it calls `sendAction` or a helper that only calls `sendAction`, and renders from kit `state` / `statePublisher`
