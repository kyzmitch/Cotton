public struct CottonLogger: Sendable {
    public let category: LogCategory

    public init(_ category: LogCategory) {
        self.category = category
    }

    public func debug(
        _ message: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        emit(.debug, message: message, file: file, function: function, line: line)
    }

    public func info(
        _ message: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        emit(.info, message: message, file: file, function: function, line: line)
    }

    public func warning(
        _ message: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        emit(.warning, message: message, file: file, function: function, line: line)
    }

    public func error(
        _ message: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        emit(.error, message: message, file: file, function: function, line: line)
    }

    public func fault(
        _ message: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        emit(.fault, message: message, file: file, function: function, line: line)
    }

    private func emit(
        _ level: LogLevel,
        message: () -> String,
        file: String,
        function: String,
        line: Int
    ) {
        guard level >= LoggerConfiguration.minimumLevel else {
            return
        }
        let resolvedMessage = message()
        LoggerConfiguration.backend.log(
            level,
            category: category,
            message: resolvedMessage,
            file: file,
            function: function,
            line: line
        )
    }
}

public extension CottonLogger {
    static let networking = CottonLogger(.networking)
    static let plugins = CottonLogger(.plugins)
    static let restKit = CottonLogger(.restKit)
    static let tabs = CottonLogger(.tabs)
    static let search = CottonLogger(.search)
    static let viewModels = CottonLogger(.viewModels)
    static let featureFlags = CottonLogger(.featureFlags)
    static let webView = CottonLogger(.webView)
    static let ui = CottonLogger(.ui)
    static let downloads = CottonLogger(.downloads)
    static let coordinator = CottonLogger(.coordinator)
    static let general = CottonLogger(.general)
}
