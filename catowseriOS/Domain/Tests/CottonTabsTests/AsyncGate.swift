//
//  AsyncGate.swift
//  CottonTabsTests
//

actor AsyncGate {
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
