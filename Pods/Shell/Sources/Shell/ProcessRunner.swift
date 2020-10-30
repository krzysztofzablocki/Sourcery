import Foundation
import PathKit

public protocol ProcessRunning {
    /// Runs the process synchronously and returns the result.
    ///
    /// - Parameters:
    ///   - arguments: Command arguments.
    ///   - shouldBeTerminatedOnParentExit: When true, the task terminates when the current process exits.
    ///   - workingDirectoryPath: Directory where the task is executed from.
    ///   - env: Environment variables to be exposed to the task.
    ///   - onStdout: Called when new data if forwarded through the standard output.
    ///   - onStderr: Called when new data is forwarded through the standard error.
    /// - Returns: Task execution result.
    func runSync(arguments: [String],
                 shouldBeTerminatedOnParentExit: Bool,
                 workingDirectoryPath: Path?,
                 env: [String: String]?,
                 onStdout: @escaping (Data) -> Void,
                 onStderr: @escaping (Data) -> Void) -> Result<Void, ProcessRunnerError>

    /// Runs the process asynchronously.
    ///
    /// - Parameters:
    ///   - arguments: Command arguments.
    ///   - shouldBeTerminatedOnParentExit: When true, the task terminates when the current process exits.
    ///   - workingDirectoryPath: Directory where the task is executed from.
    ///   - env: Environment variables to be exposed to the task.
    ///   - onStdout: Called when new data if forwarded through the standard output.
    ///   - onStderr: Called when new data is forwarded through the standard error.
    ///   - onCompletion: Called when the task completes.
    /// - Returns: Task execution result.
    func runAsync(arguments: [String],
                  shouldBeTerminatedOnParentExit: Bool,
                  workingDirectoryPath: Path?,
                  env: [String: String]?,
                  onStdout: @escaping (Data) -> Void,
                  onStderr: @escaping (Data) -> Void,
                  onCompletion: @escaping (Result<Void, ProcessRunnerError>) -> Void)
}

public final class ProcessRunner: ProcessRunning {
    /// Instance to interact with the environment.
    private let environment: EnvironmentProtocol

    /// Initializes the task runner with its attributes.
    ///
    /// - Parameter environment: Instance to interact with the environment.
    init(environment: EnvironmentProtocol = Environment()) {
        self.environment = environment
    }

    /// Runs the process synchronously and returns the result.
    ///
    /// - Parameters:
    ///   - arguments: Command arguments.
    ///   - shouldBeTerminatedOnParentExit: When true, the task terminates when the current process exits.
    ///   - workingDirectoryPath: Directory where the task is executed from.
    ///   - env: Environment variables to be exposed to the task.
    ///   - onStdout: Called when new data if forwarded through the standard output.
    ///   - onStderr: Called when new data is forwarded through the standard error.
    /// - Returns: Task execution result.
    public func runSync(arguments: [String],
                        shouldBeTerminatedOnParentExit: Bool,
                        workingDirectoryPath: Path?,
                        env: [String: String]? = nil,
                        onStdout: @escaping (Data) -> Void,
                        onStderr: @escaping (Data) -> Void) -> Result<Void, ProcessRunnerError> {
        let queue = DispatchQueue(label: "io.tuist.shell",
                                  qos: .default,
                                  attributes: [],
                                  autoreleaseFrequency: .inherit)
        let processResult = self.process(arguments: arguments,
                                         shouldBeTerminatedOnParentExit: shouldBeTerminatedOnParentExit,
                                         workingDirectoryPath: workingDirectoryPath,
                                         env: env,
                                         queue: queue,
                                         onStdout: onStdout,
                                         onStderr: onStderr)
        if processResult.error != nil {
            return processResult.map { _ in () }
        }

        let process = processResult.value!
        process.launch()
        process.waitUntilExit()

        return queue.sync {
            if process.terminationStatus != 0 {
                return .failure(.shell(reason: process.terminationReason, code: process.terminationStatus))
            } else {
                return .success(())
            }
        }
    }

    /// Runs the process asynchronously.
    ///
    /// - Parameters:
    ///   - arguments: Command arguments.
    ///   - shouldBeTerminatedOnParentExit: When true, the task terminates when the current process exits.
    ///   - workingDirectoryPath: Directory where the task is executed from.
    ///   - env: Environment variables to be exposed to the task.
    ///   - onStdout: Called when new data if forwarded through the standard output.
    ///   - onStderr: Called when new data is forwarded through the standard error.
    ///   - onCompletion: Called when the task completes.
    public func runAsync(arguments: [String],
                         shouldBeTerminatedOnParentExit: Bool,
                         workingDirectoryPath: Path?,
                         env: [String: String]?,
                         onStdout: @escaping (Data) -> Void,
                         onStderr: @escaping (Data) -> Void,
                         onCompletion: @escaping (Result<Void, ProcessRunnerError>) -> Void) {
        let queue = DispatchQueue(label: "io.tuist.shell",
                                  qos: .default,
                                  attributes: [],
                                  autoreleaseFrequency: .inherit)
        let processResult = self.process(arguments: arguments,
                                         shouldBeTerminatedOnParentExit: shouldBeTerminatedOnParentExit,
                                         workingDirectoryPath: workingDirectoryPath,
                                         env: env,
                                         queue: queue,
                                         onStdout: onStdout,
                                         onStderr: onStderr)
        if processResult.error != nil {
            onCompletion(processResult.map { _ in () })
            return
        }

        let process = processResult.value!
        process.launch()
        process.terminationHandler = { process in
            queue.async {
                if process.terminationStatus != 0 {
                    onCompletion(.failure(.shell(reason: process.terminationReason, code: process.terminationStatus)))
                } else {
                    onCompletion(.success(()))
                }
            }
        }
    }

    // MARK: - Private

    /// Returns a process instance that runs the task.
    ///
    /// - Parameters:
    ///   - arguments: Command arguments.
    ///   - shouldBeTerminatedOnParentExit: When true, the task terminates when the current process exits.
    ///   - workingDirectoryPath: Directory where the task is executed from.
    ///   - env: Environment variables to be exposed to the task.
    ///   - queue: Queue to serialize output events.
    ///   - onStdout: Called when new data if forwarded through the standard output.
    ///   - onStderr: Called when new data is forwarded through the standard error.
    /// - Returns: A result with either the process instance or a process runner error.
    private func process(arguments: [String],
                         shouldBeTerminatedOnParentExit: Bool,
                         workingDirectoryPath: Path?,
                         env: [String: String]?,
                         queue: DispatchQueue,
                         onStdout: @escaping (Data) -> Void,
                         onStderr: @escaping (Data) -> Void) -> Result<Process, ProcessRunnerError> {
        precondition(arguments.count > 0 && !arguments[0].isEmpty, "At least one argument is required")

        guard let launchpath = self.lookupExecutable(arguments[0]) else {
            return .failure(ProcessRunnerError.missingExecutable(arguments[0]))
        }

        let process = Process()
        process.launchPath = launchpath.string
        process.arguments = Array(arguments.dropFirst())

        if shouldBeTerminatedOnParentExit {
            // This is for terminating subprocesses when the parent process exits.
            // See https://github.com/Carthage/ReactiveTask/issues/3 for the details.
            let selector = Selector(("setStartsNewProcessGroup:"))
            if process.responds(to: selector) {
                process.perform(selector, with: false as NSNumber)
            }
        }

        if let workingDirectoryPath = workingDirectoryPath {
            process.currentDirectoryPath = workingDirectoryPath.string
        }

        if let env = env {
            process.environment = env
        }

        // Because FileHandle's readabilityHandler might be called from a
        // different queue from the calling queue, avoid a data race by
        // protecting reads and writes to outputData and errorData on
        // a single dispatch queue.
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        outputPipe.fileHandleForReading.readabilityHandler = { handler in
            queue.async {
                let data = handler.availableData
                if data.count > 0 {
                    onStdout(data)
                }
            }
        }

        let errorPipe = Pipe()
        process.standardError = errorPipe
        errorPipe.fileHandleForReading.readabilityHandler = { handler in
            queue.async {
                let data = handler.availableData
                if data.count > 0 {
                    onStderr(data)
                }
            }
        }

        process.terminationHandler = { _ in
            queue.async {
                (process.standardOutput! as! Pipe).fileHandleForReading.readabilityHandler = nil
                (process.standardError! as! Pipe).fileHandleForReading.readabilityHandler = nil
            }
        }

        return .success(process)
    }

    /// It looks up an executable in the user environment.
    ///
    /// - Parameter name: Executable to be looked up.
    /// - Returns: Executable path if found.
    private func lookupExecutable(_ name: String) -> Path? {
        let searchPaths = environment.searchPaths()
        return environment.lookupExecutable(name: name, in: searchPaths)
    }
}
