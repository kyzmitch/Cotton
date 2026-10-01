import CottonLoggerKit
import Foundation
import Testing

private final class CapturingLogBackend: LogBackend, @unchecked Sendable {
    struct Record: Equatable {
        let level: LogLevel
        let category: LogCategory
        let message: String
    }

    private let lock = NSLock()
    private var records: [Record] = []

    func log(
        _ level: LogLevel,
        category: LogCategory,
        message: String,
        file: String,
        function: String,
        line: Int
    ) {
        lock.lock()
        defer { lock.unlock() }
        records.append(Record(level: level, category: category, message: message))
    }

    func snapshot() -> [Record] {
        lock.lock()
        defer { lock.unlock() }
        return records
    }
}

struct CottonLoggerKitTests {
    @Test func minimumLevelFiltersBelowThresholdAndSkipsAutoclosure() {
        let backend = CapturingLogBackend()
        var evaluationCount = 0

        LoggerConfiguration.withTestingConfiguration(minimumLevel: .info, backend: backend) {
            let logger = CottonLogger(.general)
            logger.debug(messageWithSideEffect(&evaluationCount))
            logger.info("delivered")
        }

        #expect(evaluationCount == 0)
        #expect(backend.snapshot() == [
            CapturingLogBackend.Record(level: .info, category: .general, message: "delivered")
        ])
    }

    @Test func aboveMinimumLevelIsDeliveredOnce() {
        let backend = CapturingLogBackend()

        LoggerConfiguration.withTestingConfiguration(minimumLevel: .info, backend: backend) {
            CottonLogger(.tabs).error("failure")
        }

        #expect(backend.snapshot().count == 1)
        #expect(backend.snapshot()[0].level == .error)
    }

    @Test func categoryRoutingUsesLoggerCategory() {
        let backend = CapturingLogBackend()

        LoggerConfiguration.withTestingConfiguration(minimumLevel: .debug, backend: backend) {
            CottonLogger(.tabs).info("tab event")
            CottonLogger(.custom("MyFeature")).warning("custom")
        }

        let records = backend.snapshot()
        #expect(records.count == 2)
        #expect(records[0].category == .tabs)
        #expect(records[1].category == .custom("MyFeature"))
    }

    @Test func messageAutoclosureEvaluatedExactlyOnceWhenLogged() {
        let backend = CapturingLogBackend()
        var evaluationCount = 0

        LoggerConfiguration.withTestingConfiguration(minimumLevel: .debug, backend: backend) {
            CottonLogger(.networking).info(messageWithSideEffect(&evaluationCount))
        }

        #expect(evaluationCount == 1)
        #expect(backend.snapshot()[0].message == "evaluated")
    }

    @Test func configurationRestoreReturnsDefaultBackend() {
        let capturing = CapturingLogBackend()
        LoggerConfiguration.backend = capturing
        LoggerConfiguration.minimumLevel = .debug
        CottonLogger(.general).info("before restore")

        LoggerConfiguration.restoreDefaults()

        let postRestore = CapturingLogBackend()
        LoggerConfiguration.backend = postRestore
        CottonLogger(.general).info("after restore")

        #expect(capturing.snapshot().count == 1)
        #expect(postRestore.snapshot().count == 1)

        LoggerConfiguration.restoreDefaults()
    }
}

@inline(never)
private func messageWithSideEffect(_ counter: inout Int) -> String {
    counter += 1
    return "evaluated"
}
