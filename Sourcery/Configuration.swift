import Foundation
import XcodeEdit
import PathKit
import Yams
import SourceryRuntime

struct Project {
    let file: XCProjectFile
    let root: Path
    let targets: [Target]
    let exclude: [Path]

    struct Target {
        let name: String
        let module: String

        init(dict: [String: String]) throws {
            guard let name = dict["name"] else {
                throw Configuration.Error.invalidSources(message: "Target name is not provided. Expected string.")
            }
            self.name = name
            self.module = dict["module"] ?? name
        }
    }

    init(dict: [String: Any], relativePath: Path) throws {
        guard let file = dict["file"] as? String else {
            throw Configuration.Error.invalidSources(message: "Project file path is not provided. Expected string.")
        }
        guard let root = dict["root"] as? String else {
            throw Configuration.Error.invalidSources(message: "Project root path is not provided. Expected string.")
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

        self.file = try XCProjectFile(path: Path(file, relativeTo: relativePath).string)
        self.root = Path(root)
    }

}

struct Paths {
    let include: [Path]
    let exclude: [Path]
    let allPaths: [Path]

    var isEmpty: Bool {
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

    init(include: [Path], exclude: [Path] = []) {
        self.include = include
        self.exclude = exclude

        let include = self.include.flatMap { $0.allPaths }
        let exclude = self.exclude.flatMap { $0.allPaths }

        self.allPaths = Array(Set(include).subtracting(Set(exclude))).sorted()
    }

}

enum Source {
    case projects([Project])
    case sources(Paths)

    init(dict: [String: Any], relativePath: Path) throws {
        if let projects = dict["project"] as? [[String: Any]] {
            guard !projects.isEmpty else { throw Configuration.Error.invalidSources(message: "No projects provided.") }
            self = try .projects(projects.map({ try Project(dict: $0, relativePath: relativePath) }))
        } else if let project = dict["project"] as? [String: Any] {
            self = try .projects([Project(dict: project, relativePath: relativePath)])
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

    var isEmpty: Bool {
        switch self {
        case let .sources(paths):
            return paths.allPaths.isEmpty
        case let .projects(projects):
            return projects.isEmpty
        }
    }
}

struct Configuration {

    enum Error: Swift.Error, CustomStringConvertible {
        case invalidFormat(message: String)
        case invalidSources(message: String)
        case invalidTemplates(message: String)
        case invalidOutput(message: String)
        case invalidPaths(message: String)

        var description: String {
            switch self {
            case .invalidFormat(let message):
                return "Invalid config file format. \(message)"
            case .invalidSources(let message):
                return "Invalid sources. \(message)"
            case .invalidTemplates(let message):
                return "Invalid templates. \(message)"
            case .invalidOutput(let message):
                return "Invalid output. \(message)"
            case .invalidPaths(let message):
                return "\(message)"
            }
        }
    }

    let source: Source
    let templates: Paths
    let output: Path
    let forceParse: [String]
    let args: [String: NSObject]

    init(path: Path, relativePath: Path) throws {
        guard let dict = try Yams.load(yaml: path.read()) as? [String: Any] else {
            throw Configuration.Error.invalidFormat(message: "Expected dictionary.")
        }

        try self.init(dict: dict, relativePath: relativePath)
    }

    init(dict: [String: Any], relativePath: Path) throws {
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

        guard let output = dict["output"] as? String else {
            throw Configuration.Error.invalidOutput(message: "'output' key is missing or is not a string.")
        }
        self.output = Path(output, relativeTo: relativePath)

        self.args = dict["args"] as? [String: NSObject] ?? [:]
    }

    init(sources: [Path], templates: [Path], output: Path, forceParse: [String], args: [String: NSObject]) {
        self.source = .sources(Paths(include: sources))
        self.templates = Paths(include: templates)
        self.output = output
        self.forceParse = forceParse
        self.args = args
    }

}
