import Foundation
import PathKit

protocol EnvironmentProtocol {
    /// It looks up an executable in the given paths and current directory.
    ///
    /// - Parameters:
    ///   - name: Name of the executable to be found.
    ///   - paths: Paths where the executable should be looked up in.
    /// - Returns: Executable path if it was found.
    func lookupExecutable(name: String, in paths: [Path]) -> Path?

    /// Returns the list of paths where executables can be found.
    ///
    /// - Returns: List of paths exposed through the PATH environment variable.
    func searchPaths() -> [Path]
}

class Environment: EnvironmentProtocol {
    /// Returns the list of paths where executables can be found.
    ///
    /// - Returns: List of paths exposed through the PATH environment variable.
    func searchPaths() -> [Path] {
        return searchPaths(pathString: ProcessInfo.processInfo.environment["PATH"],
                           currentWorkingDirectory: Path.current)
    }

    /// Returns the list of paths where executables can be found.
    ///
    /// - Parameters:
    ///   - pathString: The value of the environment variable PATH.
    ///   - currentWorkingDirectory: Path to the current working directory.
    /// - Returns: List of paths exposed through the PATH environment variable.
    func searchPaths(pathString: String?, currentWorkingDirectory: Path) -> [Path] {
        return (pathString ?? "").split(separator: ":").map(String.init).compactMap { pathString in
            if pathString.first == "/" {
                return Path(pathString)
            }
            return currentWorkingDirectory + pathString
        }
    }

    /// It looks up an executable in the given paths and current directory.
    ///
    /// - Parameters:
    ///   - name: Name of the executable to be found.
    ///   - paths: Paths where the executable should be looked up in.
    /// - Returns: Executable path if it was found.
    func lookupExecutable(name: String, in paths: [Path]) -> Path? {
        return lookupExecutable(name: name,
                                in: paths,
                                currentWorkingDirectory: Path.current)
    }

    /// It looks up an executable in the given paths and current directory.
    ///
    /// - Parameters:
    ///   - name: Name of the executable to be found.
    ///   - paths: Paths where the executable should be looked up in.
    ///   - currentWorkingDirectory: User current working directory in which to look up the executable as well.
    /// - Returns: Executable path if it was found.
    func lookupExecutable(name: String, in paths: [Path], currentWorkingDirectory: Path) -> Path? {
        let path = Path(name)

        // Return in case the name is already an absolute path
        switch (path.isAbsolute, path.exists, path.isExecutable) {
        case (true, true, true):
            return path
        case (true, _, _):
            return nil
        default:
            break
        }

        var paths = paths
        paths.insert(currentWorkingDirectory, at: 0)

        for path in paths {
            let path = path + name
            if path.exists, path.isExecutable {
                return path
            }
        }
        return nil
    }
}
