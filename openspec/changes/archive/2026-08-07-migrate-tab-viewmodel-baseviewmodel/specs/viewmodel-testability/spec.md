## ADDED Requirements

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
