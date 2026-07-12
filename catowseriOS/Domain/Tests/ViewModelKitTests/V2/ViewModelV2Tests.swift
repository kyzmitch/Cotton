import XCTest
@testable import ViewModelKit

class ViewModelV2Tests: XCTestCase {
    
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
        let viewModel = ViewModelV2<TestState, TestEvent>(
            initialState: .idle,
            stateTransitions: [
                .startLoading: { _ in .loading },
                .finishLoading: { _ in .success },
                .failLoading: { error in .error(error) }
            ]
        )
        
        XCTAssertEqual(viewModel.state, .idle)
    }
    
    func testStateChange() {
        let viewModel = ViewModelV2<TestState, TestEvent>(
            initialState: .idle,
            stateTransitions: [
                .startLoading: { _ in .loading },
                .finishLoading: { _ in .success },
                .failLoading: { error in .error(error) }
            ]
        )
        
        viewModel.send(.startLoading)
        XCTAssertEqual(viewModel.state, .loading)
        
        viewModel.send(.finishLoading)
        XCTAssertEqual(viewModel.state, .success)
        
        viewModel.send(.failLoading("Network error"))
        if case let .error(error) = viewModel.state {
            XCTAssertEqual(error, "Network error")
        } else {
            XCTFail("Expected error state")
        }
    }
    
    func testViewModelStateAccess() {
        let viewModel = ViewModelV2<TestState, TestEvent>(
            initialState: .idle,
            stateTransitions: [
                .startLoading: { _ in .loading }
            ]
        )
        
        XCTAssertEqual(viewModel.state, .idle)
        
        viewModel.send(.startLoading)
        XCTAssertEqual(viewModel.state, .loading)
    }
}
