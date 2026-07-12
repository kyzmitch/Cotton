import Testing
@testable import ViewModelKit

struct ViewModelV2Tests {

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

    @Test func initialState() {
        let viewModel = ViewModelV2<TestState, TestEvent>(
            initialState: .idle,
            stateTransitions: [
                .startLoading: { _ in .loading },
                .finishLoading: { _ in .success },
                .failLoading: { error in .error(error) }
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
                .failLoading: { error in .error(error) }
            ]
        )

        viewModel.send(.startLoading)
        #expect(viewModel.state == .loading)

        viewModel.send(.finishLoading)
        #expect(viewModel.state == .success)

        viewModel.send(.failLoading("Network error"))
        #expect(viewModel.state == .error("Network error"))
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

