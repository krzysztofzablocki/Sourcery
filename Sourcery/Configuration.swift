import Foundation
import XcodeProj
import PathKit
import Yams
import SourceryRuntime
import QuartzCore
import Basics
import TSCBasic
import Workspace
import PackageModel

public struct Project {
    public let file: XcodeProj
    public let root: Path
    public let targets: [Target]
    public let exclude: [Path]

    public struct Target {

        public struct XCFramework {

            public let path: Path
            public let swiftInterfacePath: Path

            public init(rawPath: String, relativePath: Path) throws {
                let frameworkRelativePath = Path(rawPath, relativeTo: relativePath)
                guard let framework = frameworkRelativePath.components.last else {
                    throw Configuration.Error.invalidXCFramework(message: "Framework path invalid. Expected String.")
                }
                let `extension` = Path(framework).`extension`
                guard `extension` == "xcframework" else {
                    throw Configuration.Error.invalidXCFramework(message: "Framework path invalid. Expected path to xcframework file.")
                }
                let moduleName = Path(framework).lastComponentWithoutExtension
                guard
                    let simulatorSlicePath = frameworkRelativePath.glob("*")
                        .first(where: { $0.lastComponent.contains("simulator") })
                else {
                    throw Configuration.Error.invalidXCFramework(path: frameworkRelativePath, message: "Framework path invalid. Expected to find simulator slice.")
                }
                let modulePath = simulatorSlicePath + Path("\(moduleName).framework/Modules/\(moduleName).swiftmodule/")
                guard let interfacePath = modulePath.glob("*.swiftinterface").first(where: { $0.lastComponent.contains("simulator") })
                else {
                    throw Configuration.Error.invalidXCFramework(path: frameworkRelativePath, message: "Framework path invalid. Expected to find .swiftinterface.")
                }
                self.path = frameworkRelativePath
                self.swiftInterfacePath = interfacePath
            }
        }

        public let name: String
        public let module: String
        public let xcframeworks: [XCFramework]

        public init(dict: [String: Any], relativePath: Path) throws {
            guard let name = dict["name"] as? String else {
                throw Configuration.Error.invalidSources(message: "Target name is not provided. Expected string.")
            }
            self.name = name
            self.module = (dict["module"] as? String) ?? name
            do {
                self.xcframeworks = try (dict["xcframeworks"] as? [String])?
                    .map { try XCFramework(rawPath: $0, relativePath: relativePath) } ?? []
            } catch let error as Configuration.Error {
                Log.warning(error.description)
                self.xcframeworks = []
            }
        }
    }

    public init(dict: [String: Any], relativePath: Path) throws {
        guard let file = dict["file"] as? String else {
            throw Configuration.Error.invalidSources(message: "Project file path is not provided. Expected string.")
        }

        let targetsArray: [Target]
        if let targets = dict["target"] as? [[String: Any]] {
            targetsArray = try targets.map({ try Target(dict: $0, relativePath: relativePath) })
        } else if let target = dict["target"] as? [String: Any] {
            targetsArray = try [Target(dict: target, relativePath: relativePath)]
        } else {
            throw Configuration.Error.invalidSources(message: "'target' key is missing. Expected object or array of objects.")
        }
        guard !targetsArray.isEmpty else {
            throw Configuration.Error.invalidSources(message: "No targets provided.")
        }
        self.targets = targetsArray

        let exclude = (dict["exclude"] as? [String])?.map({ Path($0, relativeTo: relativePath) }) ?? []
        self.exclude = exclude.flatMap { $0.allPaths }

        let path = Path(file, relativeTo: relativePath)
        self.file = try XcodeProj(path: path)
        self.root = path.parent()
    }

}

public struct Paths {
    public let include: [Path]
    public let exclude: [Path]
    public let allPaths: [Path]

    public var isEmpty: Bool {
        return allPaths.isEmpty
    }

    public init(dict: Any, relativePath: Path) throws {
        if let sources = dict as? [String: [String]],
            let include = sources["include"]?.map({ Path($0, relativeTo: relativePath) }) {

            let exclude = sources["exclude"]?.map({ Path($0, relativeTo: relativePath) }) ?? []
            self.init(include: include, exclude: exclude)
        } else if let sources = dict as? [String] {

            let sources = sources.map({ Path($0, relativeTo: relativePath) })
            guard !sources.isEmpty else {
                throw Configuration.Error.invalidPaths(message: "No paths provided.")
            }
            self.init(include: sources)
        } else {
            throw Configuration.Error.invalidPaths(message: "No paths provided. Expected list of strings or object with 'include' and optional 'exclude' keys.")
        }
    }

    public init(include: [Path], exclude: [Path] = []) {
        self.include = include
        self.exclude = exclude

        let include = self.include.parallelFlatMap { $0.processablePaths }
        let exclude = self.exclude.parallelFlatMap { $0.processablePaths }

        self.allPaths = Array(Set(include).subtracting(Set(exclude))).sorted()
    }

}

extension Path {
    public var processablePaths: [Path] {
        if isDirectory {
            return (try? recursiveUnhiddenChildren()) ?? []
        } else {
            return [self]
        }
    }

    public func recursiveUnhiddenChildren() throws -> [Path] {
        FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.pathKey], options: [.skipsHiddenFiles, .skipsPackageDescendants], errorHandler: nil)?.compactMap { object in
            if let url = object as? URL {
                return self + Path(url.path)
            }
            return nil
        } ?? []
    }
}

public struct Package {
    public let root: Path
    public let targets: [Target]

    public struct Target {
        let name: String
        let root: Path
        let excludes: [Path]
    }

    public init(dict: [String: Any], relativePath: Path) throws {
        guard let packageRootPath = dict["path"] as? String else {
            throw Configuration.Error.invalidSources(message: "Package file directory path is not provided. Expected string.")
        }
        let path = Path(packageRootPath, relativeTo: relativePath)
        
        let packagePath = try AbsolutePath(validating: path.string)
        let observability = ObservabilitySystem { Log.verbose("\($0): \($1)") }
        let workspace = try Workspace(forRootPackage: packagePath)

        var manifestResult: Result<Manifest, Error>?
        let semaphore = DispatchSemaphore(value: 0)
        workspace.loadRootManifest(at: packagePath, observabilityScope: observability.topScope, completion: { result in
            manifestResult = result
            semaphore.signal()
        })
        semaphore.wait()
        
        guard let manifest = try manifestResult?.get() else{
            throw Configuration.Error.invalidSources(message: "Unable to load manifest")
        }
        self.root = path
        let targetNames: [String]
        if let targets = dict["target"] as? [String] {
            targetNames = targets
        } else if let target = dict["target"] as? String {
            targetNames = [target]
        } else {
            throw Configuration.Error.invalidSources(message: "'target' key is missing. Expected object or array of objects.")
        }
        let sourcesPath = Path("Sources", relativeTo: path)
        self.targets = manifest.targets.compactMap({ target in
            guard targetNames.contains(target.name) else {
                return nil
            }
            let rootPath = target.path.map { Path($0, relativeTo: path) } ?? Path(target.name, relativeTo: sourcesPath)
            let excludePaths = target.exclude.map { path in
                Path(path, relativeTo: rootPath)
            }
            return Target(name: target.name, root: rootPath, excludes: excludePaths)
        })
    }
}

public enum Source {
    case projects([Project])
    case sources(Paths)
    case packages([Package])

    public init(dict: [String: Any], relativePath: Path) throws {
        if let projects = (dict["project"] as? [[String: Any]]) ?? (dict["project"] as? [String: Any]).map({ [$0] }) {
            guard !projects.isEmpty else { throw Configuration.Error.invalidSources(message: "No projects provided.") }
            self = try .projects(projects.map({ try Project(dict: $0, relativePath: relativePath) }))
        } else if let sources = dict["sources"] {
            do {
                self = try .sources(Paths(dict: sources, relativePath: relativePath))
            } catch {
                throw Configuration.Error.invalidSources(message: "\(error)")
            }
        } else if let packages = (dict["package"] as? [[String: Any]]) ?? (dict["package"] as? [String: Any]).map({ [$0] }) {
            guard !packages.isEmpty else { throw Configuration.Error.invalidSources(message: "No packages provided.") }
            self = try .packages(packages.map({ try Package(dict: $0, relativePath: relativePath) }))
        } else {
            throw Configuration.Error.invalidSources(message: "'sources', 'project' or 'package' key are missing.")
        }
    }

    public var isEmpty: Bool {
        switch self {
        case let .sources(paths):
            return paths.allPaths.isEmpty
        case let .projects(projects):
            return projects.isEmpty
        case let .packages(packages):
            return packages.isEmpty
        }
    }
}

public struct Output {
    public struct LinkTo {
        public let project: XcodeProj
        public let projectPath: Path
        public let targets: [String]
        public let group: String?

        public init(dict: [String: Any], relativePath: Path) throws {
            guard let project = dict["project"] as? String else {
                throw Configuration.Error.invalidOutput(message: "No project file path provided.")
            }
            if let target = dict["target"] as? String {
                self.targets = [target]
            } else if let targets = dict["targets"] as? [String] {
                self.targets = targets
            } else {
                throw Configuration.Error.invalidOutput(message: "No target(s) provided.")
            }
            let projectPath = Path(project, relativeTo: relativePath)
            self.projectPath = projectPath
            self.project = try XcodeProj(path: projectPath)
            self.group = dict["group"] as? String
        }
    }

    public let path: Path
    public let linkTo: LinkTo?

    public var isDirectory: Bool {
        guard path.exists else {
            return path.lastComponentWithoutExtension == path.lastComponent || path.string.hasSuffix("/")
        }
        return path.isDirectory
    }

    public init(dict: [String: Any], relativePath: Path) throws {
        guard let path = dict["path"] as? String else {
            throw Configuration.Error.invalidOutput(message: "No path provided.")
        }

        self.path = Path(path, relativeTo: relativePath)

        if let linkToDict = dict["link"] as? [String: Any] {
            do {
                self.linkTo = try LinkTo(dict: linkToDict, relativePath: relativePath)
            } catch {
                self.linkTo = nil
                Log.warning(error)
            }
        } else {
            self.linkTo = nil
        }
    }

    public init(_ path: Path, linkTo: LinkTo? = nil) {
        self.path = path
        self.linkTo = linkTo
    }

}

public struct Configuration {

    public enum Error: Swift.Error, CustomStringConvertible {
        case invalidFormat(message: String)
        case invalidSources(message: String)
        case invalidXCFramework(path: Path? = nil, message: String)
        case invalidTemplates(message: String)
        case invalidOutput(message: String)
        case invalidCacheBasePath(message: String)
        case invalidPaths(message: String)

        public var description: String {
            switch self {
            case .invalidFormat(let message):
                return "Invalid config file format. \(message)"
            case .invalidSources(let message):
                return "Invalid sources. \(message)"
            case .invalidXCFramework(let path, let message):
                return "Invalid xcframework\(path.map { " at path '\($0)'" } ?? "")'. \(message)"
            case .invalidTemplates(let message):
                return "Invalid templates. \(message)"
            case .invalidOutput(let message):
                return "Invalid output. \(message)"
            case .invalidCacheBasePath(let message):
                return "Invalid cacheBasePath. \(message)"
            case .invalidPaths(let message):
                return "\(message)"
            }
        }
    }

    public let source: Source
    public let templates: Paths
    public let output: Output
    public let cacheBasePath: Path
    public let forceParse: [String]
    public let parseDocumentation: Bool
    public let baseIndentation: Int
    public let args: [String: NSObject]

    public init(
        path: Path,
        relativePath: Path,
        env: [String: String] = [:]
    ) throws {
        guard let dict = try Yams.load(yaml: path.read(), .default, Constructor.sourceryContructor(env: env)) as? [String: Any] else {
            throw Configuration.Error.invalidFormat(message: "Expected dictionary.")
        }

        try self.init(dict: dict, relativePath: relativePath)
    }

    public init(dict: [String: Any], relativePath: Path) throws {
        let source = try Source(dict: dict, relativePath: relativePath)
        guard !source.isEmpty else {
            throw Configuration.Error.invalidSources(message: "No sources provided.")
        }
        self.source = source

        let templates: Paths
        guard let templatesDict = dict["templates"] else {
            throw Configuration.Error.invalidTemplates(message: "'templates' key is missing.")
        }
        do {
            templates = try Paths(dict: templatesDict, relativePath: relativePath)
        } catch {
            throw Configuration.Error.invalidTemplates(message: "\(error)")
        }
        guard !templates.isEmpty else {
            throw Configuration.Error.invalidTemplates(message: "No templates provided.")
        }
        self.templates = templates

        self.forceParse = dict["forceParse"] as? [String] ?? []

        self.parseDocumentation = dict["parseDocumentation"] as? Bool ?? false

        if let output = dict["output"] as? String {
            self.output = Output(Path(output, relativeTo: relativePath))
        } else if let output = dict["output"] as? [String: Any] {
            self.output = try Output(dict: output, relativePath: relativePath)
        } else {
            throw Configuration.Error.invalidOutput(message: "'output' key is missing or is not a string or object.")
        }

        if let cacheBasePath = dict["cacheBasePath"] as? String {
            self.cacheBasePath = Path(cacheBasePath, relativeTo: relativePath)
        } else if dict["cacheBasePath"] != nil {
            throw Configuration.Error.invalidCacheBasePath(message: "'cacheBasePath' key is not a string.")
        } else {
            self.cacheBasePath = Path.defaultBaseCachePath
        }

        self.baseIndentation = dict["baseIndentation"] as? Int ?? 0
        self.args = dict["args"] as? [String: NSObject] ?? [:]
    }

    public init(sources: Paths, templates: Paths, output: Path, cacheBasePath: Path, forceParse: [String], parseDocumentation: Bool, baseIndentation: Int, args: [String: NSObject]) {
        self.source = .sources(sources)
        self.templates = templates
        self.output = Output(output, linkTo: nil)
        self.cacheBasePath = cacheBasePath
        self.forceParse = forceParse
        self.parseDocumentation = parseDocumentation
        self.baseIndentation = baseIndentation
        self.args = args
    }

}

public enum Configurations {
    public static func make(
        path: Path,
        relativePath: Path,
        env: [String: String] = [:]
    ) throws -> [Configuration] {
        guard let dict = try Yams.load(yaml: path.read(), .default, Constructor.sourceryContructor(env: env)) as? [String: Any] else {
            throw Configuration.Error.invalidFormat(message: "Expected dictionary.")
        }

        let start = CFAbsoluteTimeGetCurrent()
        defer {
            Log.benchmark("Resolving configurations took \(CFAbsoluteTimeGetCurrent() - start)")
        }

        if let configurations = dict["configurations"] as? [[String: Any]] {
            return try configurations.map { dict in
                try Configuration(dict: dict, relativePath: relativePath)
            }
        } else {
            return try [Configuration(dict: dict, relativePath: relativePath)]
        }
    }
}

// Copied from https://github.com/realm/SwiftLint/blob/0.29.2/Source/SwiftLintFramework/Models/YamlParser.swift
// and https://github.com/SwiftGen/SwiftGen/blob/6.1.0/Sources/SwiftGenKit/Utils/YAML.swift

private extension Constructor {
    static func sourceryContructor(env: [String: String]) -> Constructor {
        return Constructor(customScalarMap(env: env))
    }

    static func customScalarMap(env: [String: String]) -> ScalarMap {
        var map = defaultScalarMap
        map[.str] = String.constructExpandingEnvVars(env: env)
        return map
    }
}

private extension String {
    static func constructExpandingEnvVars(env: [String: String]) -> (_ scalar: Node.Scalar) -> String? {
        return { (scalar: Node.Scalar) -> String? in
            scalar.string.expandingEnvVars(env: env)
        }
    }

    func expandingEnvVars(env: [String: String]) -> String? {
        // check if entry has an env variable
        guard let match = self.range(of: #"\$\{(.)\w+\}"#, options: .regularExpression) else {
            return self
        }

        // get the env variable as "${ENV_VAR}"
        let key = String(self[match])

        // get the env variable as "ENV_VAR" - note missing $ and brackets
        let keyString = String(key[2..<key.count-1])

        guard let value = env[keyString] else { return "" }

        return self.replacingOccurrences(of: key, with: value)
    }
}

private extension StringProtocol {
    subscript(bounds: CountableClosedRange<Int>) -> SubSequence {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(start, offsetBy: bounds.count)
        return self[start..<end]
    }

    subscript(bounds: CountableRange<Int>) -> SubSequence {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(start, offsetBy: bounds.count)
        return self[start..<end]
    }
}
