import Foundation

/// A generic state machine for managing view model states
public class StateMachineV2<State, Event: Hashable> {
    public private(set) var currentState: State
    private let stateTransitions: [Event: (State) -> State]

    public init(initialState: State, stateTransitions: [Event: (State) -> State]) {
        self.currentState = initialState
        self.stateTransitions = stateTransitions
    }

    public func send(_ event: Event) {
        guard let transition = stateTransitions[event] else { return }
        currentState = transition(currentState)
    }
}
