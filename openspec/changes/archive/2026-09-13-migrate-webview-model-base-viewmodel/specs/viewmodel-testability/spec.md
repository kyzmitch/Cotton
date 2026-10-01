## ADDED Requirements

### Requirement: Multi-step async adopter strategies are testable in isolation
For CottonViewModels adopters whose transitions await context (including WebViewModel-style DoH/DNS/plugin flows), tests MUST be able to drive the adopter’s `StateTransitioning` implementation with a fake/real context and assert next state, thrown domain errors, and that failed transitions leave an externally observed prior state unchanged when exercised through the state machine or `sendAction`.

New tests for this coverage MUST use the Swift Testing framework.

#### Scenario: Fake context async branch
- **WHEN** a test configures a fake WebView (or similar) context to return a predetermined DoH or DNS result
- **THEN** invoking the strategy with a given state and action yields the expected next state without UI

#### Scenario: Illegal multi-step action
- **WHEN** a test sends an illegal action for a mid-pipeline WebView domain state through the strategy or view model
- **THEN** the test observes the domain error and unchanged domain state

#### Scenario: sendAction with substituted strategy
- **WHEN** a test substitutes a fake `StateTransitioning` on a `BaseViewModel` subclass via package/test hooks
- **THEN** it can assert recorded actions and published state updates for the WebView (or similar) adopter without full app assembly
