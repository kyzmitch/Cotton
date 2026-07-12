import XCTest
@testable import ViewModelKit

class StateMachineV2Tests: XCTestCase {
    
    enum TestState: Equatable {
        case idle
        case loading
        case success
        case error(String)
    }
    
    enum TestEvent: Equatable {
        case startLoading
        case finishLoading
        case failLoading(String)
    }
    
    func testInitialState() {
        let stateMachine = StateMachineV2<TestState, TestEvent>(
            initialState: .idle,
            stateTransitions: [
                .startLoading: { _ in .loading },
                .finishLoading: { _ in .success },
                .failLoading: { error in .error(error) }
            ]
        )
        
        XCTAssertEqual(stateMachine.currentState, .idle)
    }
    
    func testStateTransition() {
        var stateMachine = StateMachineV2<TestState, TestEvent>(
            initialState: .idle,
            stateTransitions: [
                .startLoading: { _ in .loading },
                .finishLoading: { _ in .success },
                .failLoading: { error in .error(error) }
            ]
        )
        
        stateMachine.send(.startLoading)
        XCTAssertEqual(stateMachine.currentState, .loading)
        
        stateMachine.send(.finishLoading)
        XCTAssertEqual(stateMachine.currentState, .success)
        
        stateMachine.send(.failLoading("Network error"))
        if case let .error(error) = stateMachine.currentState {
            XCTAssertEqual(error, "Network error")
        } else {
            XCTFail("Expected error state")
        }
    }
    
    func testUnrecognizedEvent() {
        let stateMachine = StateMachineV2<TestState, TestEvent>(
            initialState: .idle,
            stateTransitions: [
                .startLoading: { _ in .loading }
            ]
        )
        
        let originalState = stateMachine.currentState
        stateMachine.send(.finishLoading) // This event is not handled
        XCTAssertEqual(stateMachine.currentState, originalState)
    }
}
