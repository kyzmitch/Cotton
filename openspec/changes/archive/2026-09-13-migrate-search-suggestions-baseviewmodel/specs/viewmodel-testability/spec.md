## ADDED Requirements

### Requirement: Progressive async adopter strategies are testable in isolation
For CottonViewModels adopters whose user-visible flow publishes an intermediate state then a final state across sequenced `sendAction` calls (SearchSuggestions-style known-domains then autocomplete), tests MUST be able to:

- Drive the adopter’s `StateTransitioning` implementation with a fake/real context per action and assert next state or thrown domain errors
- Assert that a failed/illegal second-step transition leaves the already-published intermediate state unchanged when exercised through the state machine or `sendAction`
- Cover the orchestration helper (if present) so both progressive publishes are observable without UIKit/SwiftUI views

New tests for this coverage MUST use the Swift Testing framework.

#### Scenario: Fake context known-domains step
- **WHEN** a test configures a fake SearchSuggestions context to return predetermined domain names
- **THEN** invoking the strategy with `.loadKnownDomains` (or equivalent) yields `.knownDomainsLoaded` without UI

#### Scenario: Fake context suggestions step
- **WHEN** a test configures a fake context to return predetermined autocomplete suggestions (or to throw)
- **THEN** invoking the strategy with `.loadSuggestions` (or equivalent) from a known-domains-bearing state yields `.everythingLoaded` with suggestions or empty suggestions on soft-fail, without UI

#### Scenario: Illegal second step preserves intermediate state
- **WHEN** a test sends an illegal suggestions-load action from `.waitingForQuery` through the strategy or view model
- **THEN** the test observes the domain error and unchanged domain state

#### Scenario: sendAction with substituted strategy
- **WHEN** a test substitutes a fake `StateTransitioning` on a `BaseViewModel` subclass via package/test hooks
- **THEN** it can assert recorded actions and published state updates for the SearchSuggestions adopter without full app assembly
