import Foundation
import class Foundation.ProcessInfo
import PathKit

/// Class tu run commands in the system.
open class Shell {
    /// Process runner.
    public let runner: ProcessRunning

    /// Public constructor.
    public convenience init() {
        self.init(runner: ProcessRunner())
    }

    /// Initializes the shell with its attributes.
    ///
    /// - Parameter runner: Instance to run the commands in the system.
    public init(runner: ProcessRunning) {
        self.runner = runner
    }

    /// Looks up an executable with the given name and returns its path if it was found.
    ///
    /// - Parameter name: Executable name.
    /// - Returns: Executable path.
    public static func lookupExecutable(_ name: String) -> Path? {
        let environment = Environment()
        let searchPaths = environment.searchPaths()
        return environment.lookupExecutable(name: name, in: searchPaths)
    }

    /// Returns true if the given command succeeds.
    ///
    /// - Parameter arguments: Command arguments.
    /// - Returns: True if the command succeeds.
    public func succeeds(_ arguments: [String]) -> Bool {
        return self.sync(arguments).error == nil
    }

    /// Runs a given command and returns its result synchronously.
    ///
    /// - Parameter arguments: Command arguments.
    /// - Returns: Command result.
    public func sync(_ arguments: [String]) -> Result<Void, ShellError> {
        return self.sync(arguments,
                         shouldBeTerminatedOnParentExit: true,
                         workingDirectoryPath: nil,
                         env: nil,
                         onStdout: nil,
                         onStderr: nil)
    }

    /// Runs a given command and returns its result synchronously.
    ///
    /// - Parameters:
    ///   - arguments: Command arguments.
    ///   - shouldBeTerminatedOnParentExit: When true, it kills the task when the current process terminates.
    ///   - workingDirectoryPath: Directory the process should be run from.
    ///   - env: Environment variables to be exposed to the command.
    ///   - onStdout: Closure to send the standard output through.
    ///   - onStderr: Closure to send the standard error through.
    /// - Returns: Command result.
    public func sync(_ arguments: [String],
                     shouldBeTerminatedOnParentExit: Bool,
                     workingDirectoryPath: Path?,
                     env: [String: String]?,
                     onStdout: ((String) -> Void)?,
                     onStderr: ((String) -> Void)?) -> Result<Void, ShellError> {
        let onStdoutData: (Data) -> Void = { data in
            if let onStdout = onStdout, let string = String(data: data, encoding: .utf8) {
                onStdout(string)
            }
        }
        let onStderrData: (Data) -> Void = { data in
            if let onStderr = onStderr, let string = String(data: data, encoding: .utf8) {
                onStderr(string)
            }
        }
        let result = self.runner.runSync(arguments: arguments,
                                         shouldBeTerminatedOnParentExit: shouldBeTerminatedOnParentExit,
                                         workingDirectoryPath: workingDirectoryPath,
                                         env: env,
                                         onStdout: onStdoutData,
                                         onStderr: onStderrData)
        return result.flatMapError { .failure(ShellError(processError: $0)) }
    }

    /// Runs a given command and notifies about its completion asynchronously.
    ///
    /// - Parameters:
    ///   - arguments: Command arguments.
    ///   - onCompletion: Closure to notify the completion of the task.
    public func async(_ arguments: [String], onCompletion: @escaping (Result<Void, ShellError>) -> Void) {
        self.async(arguments,
                   shouldBeTerminatedOnParentExit: true,
                   workingDirectoryPath: nil,
                   env: nil,
                   onStdout: nil,
                   onStderr: nil,
                   onCompletion: onCompletion)
    }

    /// Runs a given command and notifies about its completion asynchronously.
    ///
    /// - Parameters:
    ///   - arguments: Command arguments.
    ///   - shouldBeTerminatedOnParentExit: When true, it kills the task when the current process terminates.
    ///   - workingDirectoryPath: Directory the process should be run from.
    ///   - env: Environment variables to be exposed to the command.
    ///   - onStdout: Closure to send the standard output through.
    ///   - onStderr: Closure to send the standard error through.
    ///   - onCompletion: Closure to notify the completion of the task.
    public func async(_ arguments: [String],
                      shouldBeTerminatedOnParentExit: Bool,
                      workingDirectoryPath: Path?,
                      env: [String: String]?,
                      onStdout: ((String) -> Void)?,
                      onStderr: ((String) -> Void)?,
                      onCompletion: @escaping (Result<Void, ShellError>) -> Void) {
        let onStdoutData: (Data) -> Void = { data in
            if let onStdout = onStdout, let string = String(data: data, encoding: .utf8) { onStdout(string) }
        }
        let onStderrData: (Data) -> Void = { data in
            if let onStderr = onStderr, let string = String(data: data, encoding: .utf8) { onStderr(string) }
        }
        let onRunnerCompletion: (Result<Void, ProcessRunnerError>) -> Void = { result in
            onCompletion(result.flatMapError { .failure(ShellError(processError: $0)) })
        }
        self.runner.runAsync(arguments: arguments,
                             shouldBeTerminatedOnParentExit: shouldBeTerminatedOnParentExit,
                             workingDirectoryPath: workingDirectoryPath,
                             env: env,
                             onStdout: onStdoutData,
                             onStderr: onStderrData,
                             onCompletion: onRunnerCompletion)
    }

    /// Runs the given command and returns the captured output.
    ///
    /// - Parameter arguments: Command arguments.
    /// - Returns: The result with either the standard output or a shell error.
    public func capture(_ arguments: [String]) -> Result<String, ShellError> {
        return self.capture(arguments, workingDirectoryPath: nil, env: nil)
    }

    /// Runs the given command and returns the captured output.
    ///
    /// - Parameters:
    ///   - arguments: Command arguments.
    ///   - workingDirectoryPath: Working directory to run the command from.
    ///   - env: Environment variables to be exposed to the command.
    /// - Returns: The result with either the standard output or a shell error.
    public func capture(_ arguments: [String],
                        workingDirectoryPath: Path?,
                        env: [String: String]?) -> Result<String, ShellError> {
        var output = ""
        var error = ""

        let onStdout: (Data) -> Void = { stdout in
            if let string = String(data: stdout, encoding: .utf8) {
                output.append(string)
            }
        }
        let onStderr: (Data) -> Void = { stderror in
            if let string = String(data: stderror, encoding: .utf8) {
                error.append(string)
            }
        }

        let result = self.runner.runSync(arguments: arguments,
                                         shouldBeTerminatedOnParentExit: true,
                                         workingDirectoryPath: workingDirectoryPath,
                                         env: env,
                                         onStdout: onStdout,
                                         onStderr: onStderr)
        if let processError = result.error {
            let shellError = ShellError(processError: processError, stderr: error)
            return .failure(shellError)
        } else {
            return .success(output)
        }
    }
}
