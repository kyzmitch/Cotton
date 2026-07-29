//
//  ViewModelStateMachineTests.swift
//  ViewModelKitTests
//

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
    @Test func sendActionUpdatesPublishedStateWithFakeStrategy() async throws {
        let viewModel = BaseViewModel<TestState, TestAction, TestContext>(
            transitioning: IncrementTransitioning()
        )
        #expect(viewModel.state.value == 0)

        try await viewModel.sendAction(.increment)
        #expect(viewModel.state.value == 1)
    }

    @MainActor
    @Test func sendActionErrorLeavesPublishedStateUnchanged() async {
        let viewModel = BaseViewModel<TestState, TestAction, TestContext>(
            transitioning: IncrementTransitioning()
        )
        viewModel.state = TestState(value: 5)

        await #expect(throws: TestError.self) {
            try await viewModel.sendAction(.fail)
        }
        #expect(viewModel.state.value == 5)
    }

    @MainActor
    @Test func testHookReplacesTransitionStrategy() async throws {
        let viewModel = BaseViewModel<TestState, TestAction, TestContext>(
            transitioning: IncrementTransitioning()
        )
        viewModel.setTransitioningForTests(
            ClosureStateTransitioning { _, _, _ in
                TestState(value: 42)
            }
        )

        try await viewModel.sendAction(.increment)
        #expect(viewModel.state.value == 42)
    }
}
