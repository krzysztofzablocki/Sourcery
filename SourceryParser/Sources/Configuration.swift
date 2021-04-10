import Foundation
import XcodeProj
import PathKit
import Yams

public struct Project {
    public let file: XcodeProj
    public let root: Path
    public let targets: [Target]
    public let exclude: [Path]

    public struct Target {
        public let name: String
        public let module: String

        init(dict: [String: String]) throws {
            guard let name = dict["name"] else {
                throw Configuration.Error.invalidSources(message: "Target name is not provided. Expected string.")
            }
            self.name = name
            self.module = dict["module"] ?? name
        }
    }

    public init(dict: [String: Any], relativePath: Path) throws {
        guard let file = dict["file"] as? String else {
            throw Configuration.Error.invalidSources(message: "Project file path is not provided. Expected string.")
        }

        let targetsArray: [Target]
        if let targets = dict["target"] as? [[String: String]] {
            targetsArray = try targets.map({ try Target(dict: $0) })
        } else if let target = dict["target"] as? [String: String] {
            targetsArray = try [Target(dict: target)]
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

    init(dict: Any, relativePath: Path) throws {
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

        let include = self.include.flatMap { $0.allPaths }
        let exclude = self.exclude.flatMap { $0.allPaths }

        self.allPaths = Array(Set(include).subtracting(Set(exclude))).sorted()
    }

}

public enum Source {
    case projects([Project])
    case sources(Paths)

    init(dict: [String: Any], relativePath: Path) throws {
        if let projects = (dict["project"] as? [[String: Any]]) ?? (dict["project"] as? [String: Any]).map({ [$0] }) {
            guard !projects.isEmpty else { throw Configuration.Error.invalidSources(message: "No projects provided.") }
            self = try .projects(projects.map({ try Project(dict: $0, relativePath: relativePath) }))
        } else if let sources = dict["sources"] {
            do {
                self = try .sources(Paths(dict: sources, relativePath: relativePath))
            } catch {
                throw Configuration.Error.invalidSources(message: "\(error)")
            }
        } else {
            throw Configuration.Error.invalidSources(message: "'sources' or 'project' key are missing.")
        }
    }

    public var isEmpty: Bool {
        switch self {
        case let .sources(paths):
            return paths.allPaths.isEmpty
        case let .projects(projects):
            return projects.isEmpty
        }
    }
}

public struct Output {
    public struct LinkTo {
        public let project: XcodeProj
        public let projectPath: Path
        public let target: String
        public let group: String?

        public init(dict: [String: Any], relativePath: Path) throws {
            guard let project = dict["project"] as? String else {
                throw Configuration.Error.invalidOutput(message: "No project file path provided.")
            }
            guard let target = dict["target"] as? String else {
                throw Configuration.Error.invalidOutput(message: "No target name provided.")
            }
            let projectPath = Path(project, relativeTo: relativePath)
            self.projectPath = projectPath
            self.project = try XcodeProj(path: projectPath)
            self.target = target
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
            self.linkTo = try? LinkTo(dict: linkToDict, relativePath: relativePath)
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

        self.forceParse = dict["force-parse"] as? [String] ?? []

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

        self.args = dict["args"] as? [String: NSObject] ?? [:]
    }

    public init(sources: Paths, templates: Paths, output: Path, cacheBasePath: Path, forceParse: [String], args: [String: NSObject]) {
        self.source = .sources(sources)
        self.templates = templates
        self.output = Output(output, linkTo: nil)
        self.cacheBasePath = cacheBasePath
        self.forceParse = forceParse
        self.args = args
    }

}

// Copied from https://github.com/realm/SwiftLint/blob/0.29.2/Source/SwiftLintFramework/Models/YamlParser.swift
// and https://github.com/SwiftGen/SwiftGen/blob/6.1.0/Sources/SwiftGenKit/Utils/YAML.swift

extension Constructor {
    public static func sourceryContructor(env: [String: String]) -> Constructor {
        return Constructor(customScalarMap(env: env))
    }

    private static func customScalarMap(env: [String: String]) -> ScalarMap {
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
