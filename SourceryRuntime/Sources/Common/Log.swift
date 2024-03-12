//import Darwin
import Foundation

/// :nodoc:
public enum Log {

    public enum Level: Int {
        case errors
        case warnings
        case info
        case verbose
    }

    public static var level: Level = .warnings
    public static var logBenchmarks: Bool = false
    public static var logAST: Bool = false

    public static var stackMessages: Bool = false
    public private(set) static var messagesStack = [String]()

    public static func error(_ message: Any) {
        log(level: .errors, "error: \(message)")
        // to return error when running swift templates which is done in a different process
        if ProcessInfo.processInfo.processName != "Sourcery" {
            fputs("\(message)", stderr)
        }
    }

    public static func warning(_ message: Any) {
        log(level: .warnings, "warning: \(message)")
    }

    public static func astWarning(_ message: Any) {
        guard logAST else { return }
        log(level: .warnings, "ast warning: \(message)")
    }

    public static func astError(_ message: Any) {
        guard logAST else { return }
        log(level: .errors, "ast error: \(message)")
    }

    public static func verbose(_ message: Any) {
        log(level: .verbose, message)
    }

    public static func info(_ message: Any) {
        log(level: .info, message)
    }

    public static func benchmark(_ message: Any) {
        guard logBenchmarks else { return }
        if stackMessages {
            messagesStack.append("\(message)")
        } else {
            print(message)
        }
    }

    private static func log(level logLevel: Level, _ message: Any) {
        guard logLevel.rawValue <= Log.level.rawValue else { return }
        if stackMessages {
            messagesStack.append("\(message)")
        } else {
            print(message)
        }
    }

    public static func output(_ message: String) {
        print(message)
    }
}

extension String: Error {}
