import OSLog
import os

public struct SystemLogBackend: LogBackend {
    private static let subsystem = "com.ae.cotton-browser"

    public init() {}

    public func log(
        _ level: LogLevel,
        category: LogCategory,
        message: String,
        file: String,
        function: String,
        line: Int
    ) {
        if #available(iOS 14.0, macOS 11.0, *) {
            let logger = Logger(
                subsystem: Self.subsystem,
                category: category.osLogCategory
            )
            switch level {
            case .debug:
                logger.debug("\(message, privacy: .public)")
            case .info:
                logger.info("\(message, privacy: .public)")
            case .warning:
                logger.log(level: .default, "\(message, privacy: .public)")
            case .error:
                logger.error("\(message, privacy: .public)")
            case .fault:
                logger.fault("\(message, privacy: .public)")
            }
        } else {
            let log = OSLog(subsystem: Self.subsystem, category: category.osLogCategory)
            os_log("%{public}@", log: log, type: level.osLogType, message)
        }
    }
}
