import Testing
@testable import ViewModelKit

struct ViewModelV2Tests {
  
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
    let viewModel = ViewModelV2<TestState, TestEvent>(
      initialState: .idle,
      stateTransitions: [
        .startLoading: { _ in .loading },
        .finishLoading: { _ in .success },
        .failLoading("Some error"): { state in .error("Some error") }
      ]
    )
    
    #expect(viewModel.state == .idle)
  }
  
  @Test func stateChange() {
    let viewModel = ViewModelV2<TestState, TestEvent>(
      initialState: .idle,
      stateTransitions: [
        .startLoading: { _ in .loading },
        .finishLoading: { _ in .success },
        .failLoading("Network error"): { _ in .error("Some error") }
      ]
    )
    
    viewModel.send(.startLoading)
    #expect(viewModel.state == .loading)
    
    viewModel.send(.finishLoading)
    #expect(viewModel.state == .success)
    
    viewModel.send(.failLoading("Network error"))
    #expect(viewModel.state == .error("Some error"))
  }
  
  @Test func viewModelStateAccess() {
    let viewModel = ViewModelV2<TestState, TestEvent>(
      initialState: .idle,
      stateTransitions: [
        .startLoading: { _ in .loading }
      ]
    )
    
    #expect(viewModel.state == .idle)
    
    viewModel.send(.startLoading)
    #expect(viewModel.state == .loading)
  }
}

