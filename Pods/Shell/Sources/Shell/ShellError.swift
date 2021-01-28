import Foundation

public struct ShellError: Error, CustomStringConvertible, Equatable {
    /// Process runner error
    public let processError: ProcessRunnerError

    /// Standard error output
    public let stderr: String?

    /// Initializes the error with its attributes.
    ///
    /// - Parameters:
    ///   - processError: Process runner error
    ///   - stderr: Standard error output
    public init(processError: ProcessRunnerError, stderr: String? = nil) {
        self.processError = processError
        self.stderr = stderr
    }

    /// Error description.
    public var description: String {
        if let stderr = stderr {
            return stderr
        } else {
            return processError.description
        }
    }

    /// Compares two instances of ShellError and returns true if both are equal.
    ///
    /// - Parameters:
    ///   - lhs: First instance to be compared.
    ///   - rhs: Second instance to be compared.
    /// - Returns: True if both instances are equal.
    public static func == (lhs: ShellError, rhs: ShellError) -> Bool {
        return lhs.processError == rhs.processError &&
            lhs.stderr == rhs.stderr
    }
}
