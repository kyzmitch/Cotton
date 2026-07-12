import Foundation

/// Generic MVVM View Model with state machine support
public class ViewModelV2<State, Event: Hashable> {
    private let stateMachine: StateMachineV2<State, Event>
    
    public init(initialState: State, stateTransitions: [Event: (State) -> State]) {
        self.stateMachine = StateMachineV2(initialState: initialState, stateTransitions: stateTransitions)
    }
    
    public var state: State {
        stateMachine.currentState
    }
    
    public func send(_ event: Event) {
        stateMachine.send(event)
    }
}
