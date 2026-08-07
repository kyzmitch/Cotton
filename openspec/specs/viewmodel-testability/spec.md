# viewmodel-testability Specification

## Purpose
ViewModelKit transition strategies and state-machine behavior are unit-testable in isolation with Swift Testing, including fake strategy injection for `BaseViewModel` and focused adopter coverage.

## Requirements

### Requirement: Transitions are unit-testable in isolation
ViewModelKit MUST allow unit tests to exercise transition strategies and the state machine without constructing UI or full app assemblies.

Tests MUST be writable with the Swift Testing framework for new coverage.

#### Scenario: Strategy-only test
- **WHEN** a test supplies a known current state, action, and fake/real context to a transition strategy
- **THEN** it can assert the next state or thrown error without creating a `BaseViewModel`

#### Scenario: Machine transition test
- **WHEN** a test drives `send` on the state machine with a controlled strategy
- **THEN** it can assert current state before/after success and unchanged state after failure

### Requirement: BaseViewModel action path is testable
It MUST be possible to unit-test `BaseViewModel` (or a concrete subclass) `sendAction` behavior by injecting or substituting the transition strategy / machine dependencies.

#### Scenario: Fake strategy injection
- **WHEN** a test installs a fake strategy that records actions and returns predetermined states
- **THEN** calling `sendAction` updates published state according to the fake and records the action

#### Scenario: Error path
- **WHEN** the fake strategy throws
- **THEN** the test observes the thrown error and unchanged published state

### Requirement: CottonViewModels adopters can add focused transition tests
After migration, kit-based CottonViewModels transition logic MUST be structured so tests can cover legal and illegal action paths per state without relying on UIKit/SwiftUI views.

#### Scenario: Illegal action coverage
- **WHEN** a test sends an illegal action for a given state through the adopter’s strategy or view model
- **THEN** the test can assert the domain error and that state did not change

### Requirement: Tab selection and favicon adopter strategies are testable in isolation
For CottonViewModels adopters whose UI chrome depends on selection and favicon/title updates (Tab-style load, apply-selection, apply-replace), tests MUST be able to:

- Drive the adopter’s `StateTransitioning` implementation with a fake/real context per action and assert next state or thrown domain errors
- Assert that a failed/illegal transition leaves published domain state unchanged when exercised through the state machine or `sendAction`
- Cover observer-equivalent actions (selection chrome flip, title/favicon replace) without UIKit/SwiftUI views or full tabs service assemblies

New tests for this coverage MUST use the Swift Testing framework.

#### Scenario: Fake context load step
- **WHEN** a test configures a fake Tab context to report selected vs deselected and a predetermined favicon
- **THEN** invoking the strategy with `.load` (or equivalent) yields the matching selected/deselected state with title and favicon without UI

#### Scenario: Fake context selection step
- **WHEN** a test invokes the strategy with `.applySelection` (or equivalent) from an existing title/favicon-bearing state
- **THEN** it yields updated selection chrome with unchanged title/favicon without UI

#### Scenario: Fake context replace step
- **WHEN** a test invokes the strategy with `.applyReplace` (or equivalent) carrying a new title and favicon
- **THEN** it yields state with those values without UI

#### Scenario: Illegal action preserves state
- **WHEN** a test sends an illegal Tab action for a given state through the strategy or view model
- **THEN** the test observes the domain error and unchanged domain state

#### Scenario: sendAction with substituted strategy
- **WHEN** a test substitutes a fake `StateTransitioning` on a `BaseViewModel` subclass via package/test hooks
- **THEN** it can assert recorded actions and published state updates for the Tab adopter without full app assembly
