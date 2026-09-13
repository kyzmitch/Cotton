//
//  CommandExecutionDataLoadTests.swift
//  GenericServiceKitTests
//

import Testing
@testable import GenericServiceKit

private enum TestKitError: DataServiceKitError, Equatable {
    case zombyInstance
    case failed

    init(zombyInstance: Bool) {
        self = .zombyInstance
    }
}

private actor AsyncGate {
    private var isOpen = false
    private var waiters: [CheckedContinuation<Void, Never>] = []
    private var enterWaiters: [CheckedContinuation<Void, Never>] = []
    private var enterCount = 0

    func wait() async {
        enterCount += 1
        let pendingEnter = enterWaiters
        enterWaiters.removeAll()
        for waiter in pendingEnter {
            waiter.resume()
        }
        if isOpen {
            return
        }
        await withCheckedContinuation { continuation in
            waiters.append(continuation)
        }
    }

    func waitForEntry() async {
        if enterCount > 0 {
            return
        }
        await withCheckedContinuation { continuation in
            enterWaiters.append(continuation)
        }
    }

    func open() {
        isOpen = true
        let pending = waiters
        waiters.removeAll()
        for waiter in pending {
            waiter.resume()
        }
    }
}

private actor LoadCache {
    var entry: CommandExecutionData<Void, Int, TestKitError> = .notStarted
    private(set) var loadCount = 0

    func loadOrJoin(
        _ operation: @escaping @Sendable () async throws -> Int
    ) async throws -> Int {
        let (next, _) = entry.startingOrJoiningLoad(operation: operation)
        entry = next
        var local = entry
        do {
            let value = try await local.loadOrJoin(operation: operation)
            entry = local
            return value
        } catch {
            entry = local
            throw error
        }
    }

    func recordLoad() {
        loadCount += 1
    }

    func snapshot() -> CommandExecutionData<Void, Int, TestKitError> {
        entry
    }
}

struct CommandExecutionDataLoadTests {
    @Test func coldCacheStartsSingleInProgressTask() async throws {
        let gate = AsyncGate()
        let cache = LoadCache()
        let task = Task {
            try await cache.loadOrJoin {
                await cache.recordLoad()
                await gate.wait()
                return 42
            }
        }

        await gate.waitForEntry()
        guard case .inProgress = await cache.snapshot() else {
            Issue.record("Expected .inProgress during the cold load")
            return
        }
        #expect(await cache.loadCount == 1)

        await gate.open()
        #expect(try await task.value == 42)
        guard case .finished(let output) = await cache.snapshot(),
              case .success(let value) = output else {
            Issue.record("Expected .finished(.success) after the load")
            return
        }
        #expect(value == 42)
    }

    @Test func concurrentCallersShareOneInFlightTask() async throws {
        let gate = AsyncGate()
        let cache = LoadCache()

        async let first = cache.loadOrJoin {
            await cache.recordLoad()
            await gate.wait()
            return 7
        }
        await gate.waitForEntry()
        async let second = cache.loadOrJoin {
            await cache.recordLoad()
            await gate.wait()
            return 99
        }
        async let third = cache.loadOrJoin {
            await cache.recordLoad()
            await gate.wait()
            return 100
        }

        await gate.open()
        let results = try await [first, second, third]
        #expect(results == [7, 7, 7])
        #expect(await cache.loadCount == 1)
    }

    @Test func cachedSuccessDoesNotReload() async throws {
        let cache = LoadCache()
        #expect(try await cache.loadOrJoin {
            await cache.recordLoad()
            return 1
        } == 1)
        #expect(try await cache.loadOrJoin {
            await cache.recordLoad()
            return 99
        } == 1)
        #expect(await cache.loadCount == 1)
        guard case .finished(let output) = await cache.snapshot(),
              case .success(let value) = output else {
            Issue.record("Expected cached success to remain .finished")
            return
        }
        #expect(value == 1)
    }

    @Test func finishedFailureRetriesFreshLoad() async throws {
        let cache = LoadCache()
        do {
            _ = try await cache.loadOrJoin {
                await cache.recordLoad()
                throw TestKitError.failed
            }
            Issue.record("Expected the first load to fail")
        } catch let error as TestKitError {
            #expect(error == .failed)
        }
        guard case .finished(let output) = await cache.snapshot(),
              case .failure(let stored) = output else {
            Issue.record("Expected .finished(.failure), not a leftover .inProgress task")
            return
        }
        #expect(stored == .failed)
        #expect(await cache.loadCount == 1)

        #expect(try await cache.loadOrJoin {
            await cache.recordLoad()
            return 3
        } == 3)
        #expect(await cache.loadCount == 2)
        guard case .finished(let retryOutput) = await cache.snapshot(),
              case .success(let value) = retryOutput else {
            Issue.record("Expected retry to store .finished(.success)")
            return
        }
        #expect(value == 3)
    }
}
