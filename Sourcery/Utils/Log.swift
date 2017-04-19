enum Log {

    enum Level: Int {
        case errors
        case warnings
        case verbose
    }

    static var level: Level = .warnings

    static func error(_ message: Any) {
        log(level: .errors, "error: \(message)")
    }

    static func warning(_ message: Any) {
        log(level: .warnings, "warning: \(message)")
    }

    static func info(_ message: Any) {
        log(level: .verbose, message)
    }

    private static func log(level logLevel: Level, _ message: Any) {
        guard logLevel.rawValue <= Log.level.rawValue else { return }
        print(message)
    }

}
