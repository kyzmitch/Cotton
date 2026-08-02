# viewmodel-state-machine Specification

## Purpose
ViewModelKit provides a generic `@MainActor` state machine that owns current view-model state and applies actions through a pluggable transition strategy, integrated with `BaseViewModel` for gradual adoption across CottonViewModels.

## Requirements

### Requirement: Generic state machine owns transitions
ViewModelKit MUST provide a generic `@MainActor` state machine that owns the current `ViewModelState` and applies actions through a pluggable transition strategy, not through methods declared on `ViewModelState`.

The machine MUST be usable as the transition engine for `BaseViewModel`.

#### Scenario: Successful async transition
- **WHEN** a valid action is sent to the machine with an optional context
- **THEN** the machine awaits the strategy, replaces its current state with the returned state, and exposes that state as current

#### Scenario: Failed transition leaves state unchanged
- **WHEN** the transition strategy throws
- **THEN** the machine MUST preserve the previous current state and surface the error to the caller

### Requirement: Pluggable transition strategy
The machine MUST accept a transition strategy that can compute the next state from `(currentState, action, context?)` as an `async throws` operation.

ViewModelKit MUST provide at least a closure-based adapter so existing CottonViewModels transition bodies can be relocated without inventing a table DSL.

#### Scenario: Closure strategy
- **WHEN** a caller constructs the machine with a closure strategy
- **THEN** sending an action invokes that closure with the current state, action, and context

#### Scenario: Custom strategy type
- **WHEN** a caller supplies a dedicated strategy type for a view model
- **THEN** the machine uses that type for all subsequent transitions

### Requirement: BaseViewModel integrates the machine
`BaseViewModel.sendAction` (and `ViewModelInterface` defaults consistent with it) MUST apply actions via the state machine and publish the resulting state on success.

`ViewModelInterface` MUST expose:
- a synchronous fire-and-forget `sendAction(_:)` for single-action sync call sites
- an awaitable `sendAction(_:)` for callers that must wait or chain in `async` contexts
- a completion-based `sendAction(_:onComplete:)` that surfaces success or failure
- synchronous and awaitable `sendActions` that apply multiple actions **in order** (for sync call sites that need sequencing without nested completion callbacks)

Subclasses MUST continue to supply optional `context` the same way they do today.

#### Scenario: sendAction updates published state
- **WHEN** completion-based `sendAction` succeeds
- **THEN** `statePublisher` emits the new state and `BaseViewModel.state` equals the machine’s current state after the transition

#### Scenario: sync sendAction schedules async transition
- **WHEN** synchronous `sendAction(_:)` or `sendAction(_:onComplete:)` is called
- **THEN** the kit schedules the awaitable transition without requiring the caller to wrap the call in a `Task`

#### Scenario: sync sendActions preserves order
- **WHEN** synchronous `sendActions` is called with multiple actions
- **THEN** the kit applies them sequentially (each completes before the next starts) and delivers one completion for the whole sequence

#### Scenario: sendAction failure
- **WHEN** `sendAction` fails because the strategy throws
- **THEN** published state remains the pre-action state and the error is delivered to the completion callback

### Requirement: Cover current CottonViewModels transition styles
The state-machine design MUST support the transition styles already used by kit-based CottonViewModels:
- async work via `StateContext`
- throwing domain errors for illegal actions
- enum, struct, and class-hierarchy states

#### Scenario: Async context-backed transition
- **WHEN** a transition requires awaiting context (e.g. load/close/select tab)
- **THEN** the machine completes only after the strategy finishes and then stores the next state

#### Scenario: Illegal action
- **WHEN** an action is invalid for the current state
- **THEN** the strategy MAY throw and the machine MUST not change state

### Requirement: Gradual adoption path
The machine and `BaseViewModel` integration MUST allow view models that are not yet kit-based (e.g. WebViewModel) to adopt later without requiring `StateMachineV2`.

`StateMachineV2` MUST NOT be the required production API for this capability.

#### Scenario: New adopter without V2
- **WHEN** a CottonViewModels type is adapted to `BaseViewModel`
- **THEN** it uses the new state machine / strategy APIs rather than `StateMachineV2`
