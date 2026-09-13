## ADDED Requirements

### Requirement: SearchSuggestions uses BaseViewModel and ViewModelStateMachine
`SearchSuggestionsViewModelImpl` MUST subclass a `BaseViewModel` typealias parameterized by SearchSuggestions domain state, `SearchSuggestionsAction`, and a SearchSuggestions `StateContext` proxy.

Domain state transitions MUST run only through `sendAction` → private `ViewModelStateMachine` → `StateTransitioning`. The implementation MUST NOT assign published domain state as the primary production path outside the machine (except transient dual-write only if required during an in-PR cutover, which MUST be removed before completion).

`StateMachineV2` / `ViewModelV2` MUST NOT be used for this adoption.

The former standalone `SearchSuggestionsViewModel` protocol MUST be replaced by the `BaseViewModel` typealias (same adoption shape as AllTabs / SearchBar).

#### Scenario: fetch goes through the machine
- **WHEN** a consumer drives a suggestions fetch via `sendAction` (or an orchestration helper that only calls `sendAction`)
- **THEN** published kit `state` / `statePublisher` advances only as a result of state-machine transitions

#### Scenario: Illegal action preserves state
- **WHEN** an action is invalid for the current `SearchSuggestionsViewState`
- **THEN** the transition strategy throws a domain error and published domain state remains unchanged

### Requirement: Async SearchSuggestions transition strategy
CottonViewModels MUST provide a dedicated `StateTransitioning` type for SearchSuggestions domain state whose `transition(from:on:with:)` is `async throws` and MAY await the SearchSuggestions `StateContext` for known-domains lookup and autocomplete suggestions.

#### Scenario: Known domains path awaits context
- **WHEN** a `.loadKnownDomains` (or equivalent) action is applied
- **THEN** the strategy awaits context-backed domain lookup and returns `.knownDomainsLoaded` with those domains

#### Scenario: Suggestions path awaits autocomplete
- **WHEN** a `.loadSuggestions` (or equivalent) action is applied from a known-domains-bearing state
- **THEN** the strategy awaits context-backed autocomplete and returns `.everythingLoaded` with domains plus suggestions

#### Scenario: Autocomplete failure soft-fails
- **WHEN** autocomplete fails after domains were loaded
- **THEN** the resulting state is `.everythingLoaded(domains, [])` (empty suggestions), matching prior product behavior

#### Scenario: Strategy without UI assembly
- **WHEN** a unit test invokes the SearchSuggestions transition strategy with a fake context
- **THEN** it can assert the next state or thrown error without constructing UIKit/SwiftUI views

### Requirement: SearchSuggestions state and action kit conformances
`SearchSuggestionsViewState` MUST conform to `ViewModelState` (including `createInitial`, associated `Action` / `Context` / `BaseState`, and `Equatable`).

`createInitial` MUST return `.waitingForQuery`.

`SearchSuggestionsAction` MUST conform to `ViewModelAction`, including a manual `allCases` list suitable for associated-value cases.

Existing presentation helpers on the state (`rowsCount`, `sectionsNumber`, `value`, `sectionTitle`) MUST remain available to UI consumers.

#### Scenario: Initial state
- **WHEN** a SearchSuggestions view model is constructed
- **THEN** kit domain state starts as `.waitingForQuery`

### Requirement: Progressive known-domains then suggestions publish
A single user query MUST still produce a published `.knownDomainsLoaded` state before the final `.everythingLoaded` state.

Because `BaseViewModel.sendAction` publishes once per successful transition, the adoption MUST use sequenced actions (e.g. load known domains, then load suggestions) or an equivalent machine-safe approach. It MUST NOT rely on ViewModelKit multi-publish-inside-one-transition, and MUST NOT drop the intermediate publish.

#### Scenario: Intermediate state is observable
- **WHEN** a fetch for query `q` runs through the adopted API
- **THEN** observers of `statePublisher` receive `.knownDomainsLoaded` before `.everythingLoaded` for that query (when domains are non-blocking relative to autocomplete)

#### Scenario: Orchestration helper only uses sendAction
- **WHEN** an optional `fetchSuggestions`-style helper exists on the view model
- **THEN** it ONLY sequences kit `sendAction` calls and does not bypass the state machine for domain state updates

### Requirement: StateContext for SearchSuggestions side effects
A SearchSuggestions `StateContext` protocol (plus proxy used as the `BaseViewModel` context type) MUST expose the side-effect operations the strategy needs without the strategy depending on `SearchSuggestionsViewModelImpl` directly.

Those operations MUST cover at least: resolving known domains for a query, and fetching autocomplete suggestions for a query (including whatever autocompletion-source input the use case requires).

`SearchViewContext` MAY remain the app/feature-flags input to the impl initializer; it is not required to be the kit `StateContext` type itself.

#### Scenario: Proxy does not leak into strategy generics beyond Context
- **WHEN** the transition strategy is typed over `State.Context`
- **THEN** it compiles and runs against the proxy/fake context without importing UI layers

### Requirement: Consumers use sendAction and statePublisher
In-repo consumers MUST drive SearchSuggestions via kit `sendAction` (and/or the orchestration helper that wraps sequenced `sendAction` calls) instead of a protocol-only `fetchSuggestions` that mutates state directly.

Factories and stored properties that previously used `any SearchSuggestionsViewModel` MUST use the `SearchSuggestionsViewModel` typealias (concrete `BaseViewModel` subclass type), consistent with other kit adopters.

Updated consumers MUST observe `statePublisher` / `state` for UI updates.

#### Scenario: Consumer fetch via kit API
- **WHEN** UI needs suggestions for the current search query
- **THEN** it calls `sendAction` (or the orchestration helper) rather than assigning domain state itself

#### Scenario: Consumer observes statePublisher
- **WHEN** UIKit/SwiftUI subscribes to SearchSuggestions model updates after migration
- **THEN** it uses `statePublisher` (or `state`) as the observation API
