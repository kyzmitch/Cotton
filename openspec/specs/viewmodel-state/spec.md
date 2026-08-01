# viewmodel-state Specification

## Purpose
`ViewModelState` describes only state identity and construction. Transition behavior lives outside the state protocol so enum, struct, and class-hierarchy models can remain pure state types.

## Requirements

### Requirement: ViewModelState is pure state
`ViewModelState` MUST describe only state identity and construction. It MUST NOT declare transition APIs such as `transitionOn`.

The protocol MUST retain:
- `associatedtype Action: ViewModelAction`
- `associatedtype Context: StateContext`
- `associatedtype BaseState` constrained so `BaseState.Action == Action` and `BaseState.Context == Context`
- `static func createInitial() -> BaseState`
- `Sendable` and `Equatable` conformance requirements

#### Scenario: Initial state factory
- **WHEN** a conforming type implements `ViewModelState`
- **THEN** callers can obtain an initial `BaseState` via `createInitial()` without invoking any transition API on the state type

#### Scenario: No transition requirement
- **WHEN** a type conforms to `ViewModelState`
- **THEN** the compiler MUST NOT require `transitionOn` (or equivalent transition methods) on that conformance

### Requirement: Value and reference states remain supported
`ViewModelState` MUST allow enum, struct, and class-based state models used by CottonViewModels (including class hierarchies that share a common `BaseState`).

#### Scenario: Enum state conformance
- **WHEN** an enum state conforms to `ViewModelState` with `BaseState` equal to itself
- **THEN** it can serve as the state type for `BaseViewModel` without transition methods on the enum

#### Scenario: Class hierarchy conformance
- **WHEN** a base class and subclasses model UI modes as reference states
- **THEN** they can share a common `BaseState` associated type while remaining `ViewModelState` conformers without protocol-level transitions
