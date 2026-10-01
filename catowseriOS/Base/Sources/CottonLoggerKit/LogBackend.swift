public protocol LogBackend: Sendable {
    func log(
        _ level: LogLevel,
        category: LogCategory,
        message: String,
        file: String,
        function: String,
        line: Int
    )
}
