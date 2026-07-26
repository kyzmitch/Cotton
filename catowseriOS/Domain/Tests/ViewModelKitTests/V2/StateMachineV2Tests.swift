import Testing
@testable import ViewModelKit

struct StateMachineV2Tests {
    
    enum TestState: Equatable {
        case idle
        case loading
        case success
        case error(String)
    }
    
    enum TestEvent: Hashable {
        case startLoading
        case finishLoading
        case failLoading(String)
    }
    
    @Test func initialState() {
        let stateMachine = StateMachineV2<TestState, TestEvent>(
            initialState: .idle,
            stateTransitions: [
                .startLoading: { _ in .loading },
                .finishLoading: { _ in .success },
                .failLoading("Some error"): { state in .error("Some error") }
            ]
        )
        
        #expect(stateMachine.currentState == .idle)
    }
    
    @Test func stateTransition() {
        var stateMachine = StateMachineV2<TestState, TestEvent>(
            initialState: .idle,
            stateTransitions: [
                .startLoading: { _ in .loading },
                .finishLoading: { _ in .success },
                .failLoading("Some error"): { state in .error("Some error") }
            ]
        )
        
        stateMachine.send(.startLoading)
        #expect(stateMachine.currentState == .loading)
        
        stateMachine.send(.finishLoading)
        #expect(stateMachine.currentState == .success)
        
        stateMachine.send(.failLoading("Network error"))
        if case let .error(error) = stateMachine.currentState {
            #expect(error == "Network error")
        } else {
            Issue.record("Expected error state")
        }
    }
    
    @Test func unrecognizedEvent() {
        let stateMachine = StateMachineV2<TestState, TestEvent>(
            initialState: .idle,
            stateTransitions: [
                .startLoading: { _ in .loading }
            ]
        )
        
        let originalState = stateMachine.currentState
        stateMachine.send(.finishLoading) // This event is not handled
        #expect(stateMachine.currentState == originalState)
    }
}
