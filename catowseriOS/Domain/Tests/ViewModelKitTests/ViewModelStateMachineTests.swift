//
//  ViewModelStateMachineTests.swift
//  ViewModelKitTests
//

import Combine
import Testing
@testable import ViewModelKit

private enum TestAction: ViewModelAction {
    case increment
    case fail

    static var allCases: [TestAction] { [.increment, .fail] }
}

@MainActor
private final class TestContext: StateContext {}

private struct TestState: ViewModelState {
    typealias Action = TestAction
    typealias Context = TestContext
    typealias BaseState = TestState

    var value: Int

    static func createInitial() -> TestState {
        TestState(value: 0)
    }
}

private enum TestError: Error {
    case intentional
}

private struct IncrementTransitioning: StateTransitioning {
    typealias State = TestState

    func transition(
        from state: TestState,
        on action: TestAction,
        with context: TestContext?
    ) async throws -> TestState {
        switch action {
        case .increment:
            return TestState(value: state.value + 1)
        case .fail:
            throw TestError.intentional
        }
    }
}

struct ViewModelStateMachineTests {
    @MainActor
    @Test func successfulAsyncTransitionUpdatesState() async throws {
        let machine = ViewModelStateMachine(
            initialState: .createInitial(),
            transitioning: IncrementTransitioning()
        )
        #expect(machine.state.value == 0)

        try await machine.send(.increment, with: nil)
        #expect(machine.state.value == 1)
    }

    @MainActor
    @Test func failedTransitionLeavesStateUnchanged() async {
        let machine = ViewModelStateMachine(
            initialState: TestState(value: 3),
            transitioning: IncrementTransitioning()
        )

        await #expect(throws: TestError.self) {
            try await machine.send(.fail, with: nil)
        }
        #expect(machine.state.value == 3)
    }

    @MainActor
    @Test func closureStrategyIsInvoked() async throws {
        var seenAction: TestAction?
        let transitioning = ClosureStateTransitioning<TestState> { state, action, _ in
            seenAction = action
            return TestState(value: state.value + 10)
        }
        let machine = ViewModelStateMachine(
            initialState: .createInitial(),
            transitioning: transitioning
        )

        try await machine.send(.increment, with: nil)
        #expect(seenAction == .increment)
        #expect(machine.state.value == 10)
    }

    @MainActor
    @Test func customStrategyTypeIsUsed() async throws {
        let machine = ViewModelStateMachine(
            initialState: .createInitial(),
            transitioning: IncrementTransitioning()
        )
        try await machine.send(.increment, with: nil)
        try await machine.send(.increment, with: nil)
        #expect(machine.state.value == 2)
    }
}

struct BaseViewModelStateMachineTests {
    @MainActor
    @Test func sendActionUpdatesPublishedStateWithFakeStrategy() async {
        let viewModel = BaseViewModel<TestState, TestAction, TestContext>(
            transitioning: IncrementTransitioning()
        )
        #expect(viewModel.state.value == 0)

        await expectSendAction(
            viewModel,
            .increment,
            succeeds: true
        ) { emissions in
            #expect(emissions.last?.value == 1)
            #expect(viewModel.state.value == 1)
        }
    }

    @MainActor
    @Test func sendActionsRunsInOrderViaCompletion() async {
        let viewModel = BaseViewModel<TestState, TestAction, TestContext>(
            transitioning: IncrementTransitioning()
        )
        #expect(viewModel.state.value == 0)

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            var emissions: [TestState] = []
            var cancellable: AnyCancellable?
            cancellable = viewModel.statePublisher.sink { emissions.append($0) }

            viewModel.sendActions([.increment, .increment]) { result in
                switch result {
                case .success:
                    #expect(emissions.map(\.value) == [0, 1, 2])
                    #expect(viewModel.state.value == 2)
                case .failure(let error):
                    Issue.record("unexpected failure: \(error)")
                }
                cancellable?.cancel()
                continuation.resume()
            }
        }
    }

    @MainActor
    @Test func sendActionErrorLeavesPublishedStateUnchanged() async {
        let viewModel = BaseViewModel<TestState, TestAction, TestContext>(
            transitioning: IncrementTransitioning()
        )
        viewModel.state = TestState(value: 5)

        await expectSendAction(
            viewModel,
            .fail,
            succeeds: false
        ) { emissions in
            // Subscribe replay + no successful publish after failure.
            #expect(emissions.map(\.value) == [5])
            #expect(viewModel.state.value == 5)
        }
    }

    @MainActor
    @Test func testHookReplacesTransitionStrategy() async {
        let viewModel = BaseViewModel<TestState, TestAction, TestContext>(
            transitioning: IncrementTransitioning()
        )
        viewModel.setTransitioningForTests(
            ClosureStateTransitioning { _, _, _ in
                TestState(value: 42)
            }
        )

        await expectSendAction(
            viewModel,
            .increment,
            succeeds: true
        ) { emissions in
            #expect(emissions.last?.value == 42)
            #expect(viewModel.state.value == 42)
        }
    }
}

@MainActor
private func expectSendAction(
    _ viewModel: BaseViewModel<TestState, TestAction, TestContext>,
    _ action: TestAction,
    succeeds: Bool,
    assertOnComplete: @escaping ([TestState]) -> Void
) async {
    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
        var emissions: [TestState] = []
        var cancellable: AnyCancellable?
        cancellable = viewModel.statePublisher.sink { emissions.append($0) }

        viewModel.sendAction(action) { result in
            switch (result, succeeds) {
            case (.success, true), (.failure, false):
                assertOnComplete(emissions)
            case (.success, false):
                Issue.record("expected failure, got success")
            case (.failure(let error), true):
                Issue.record("expected success, got failure: \(error)")
            }
            cancellable?.cancel()
            continuation.resume()
        }
    }
}
