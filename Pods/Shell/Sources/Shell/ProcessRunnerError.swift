import Foundation

public enum ProcessRunnerError: Error, CustomStringConvertible, Equatable {
    /// Thrown when the shell task failed.
    case shell(reason: Process.TerminationReason, code: Int32)

    /// Thrown when the given executable name can't be found in the environment PATH.
    case missingExecutable(String)

    /// Error description.
    public var description: String {
        switch self {
        case let .missingExecutable(name):
            return "The executable with name '\(name)' was not found"
        case let .shell(reason, code):
            switch reason {
            case .exit:
                return "The process errored with code \(code)"
            case .uncaughtSignal:
                return "The process was interrupted with code \(code)"
            @unknown default:
                fatalError()
            }
        }
    }
}
