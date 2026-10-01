import Foundation

public enum LoggerConfiguration {
    private static let lock = NSLock()

    private static var defaultMinimumLevel: LogLevel {
        #if DEBUG
        return .debug
        #else
        return .info
        #endif
    }

    nonisolated(unsafe) private static var _minimumLevel: LogLevel = defaultMinimumLevel
    nonisolated(unsafe) private static var _backend: LogBackend = SystemLogBackend()

    public static var minimumLevel: LogLevel {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _minimumLevel
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _minimumLevel = newValue
        }
    }

    public static var backend: LogBackend {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _backend
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _backend = newValue
        }
    }

    public static func restoreDefaults() {
        lock.lock()
        defer { lock.unlock() }
        _minimumLevel = defaultMinimumLevel
        _backend = SystemLogBackend()
    }

    public static func withTestingConfiguration<T>(
        minimumLevel: LogLevel? = nil,
        backend: LogBackend? = nil,
        perform: () throws -> T
    ) rethrows -> T {
        lock.lock()
        let savedMinimumLevel = _minimumLevel
        let savedBackend = _backend
        if let minimumLevel {
            _minimumLevel = minimumLevel
        }
        if let backend {
            _backend = backend
        }
        lock.unlock()

        defer {
            lock.lock()
            _minimumLevel = savedMinimumLevel
            _backend = savedBackend
            lock.unlock()
        }

        return try perform()
    }
}
