import Foundation
import XcodeEdit
import PathKit

struct Project {
    let file: XCProjectFile
    let root: Path
    let targets: [Target]
    let exclude: [Path]

    struct Target {
        let name: String
        let module: String

        init?(dict: [String: String]) {
            guard let name = dict["name"] else {
                return nil
            }
            self.name = name
            self.module = dict["module"] ?? name
        }
    }

    init?(dict: [String: Any], relativePath: Path) {
        guard let file = dict["file"] as? String,
            let project = try? XCProjectFile(path: Path(file, relativeTo: relativePath).string),
            let root = dict["root"] as? String else {
                return nil
        }
        if let targets = dict["target"] as? [[String: String]] {
            self.targets = targets.flatMap(Target.init(dict:))
        } else if let target = dict["target"] as? [String: String] {
            self.targets = [Target(dict: target)].flatMap({ $0 })
        } else {
            return nil
        }

        let exclude = (dict["exclude"] as? [String])?.map({ Path($0, relativeTo: relativePath) }) ?? []
        self.exclude = exclude.flatMap { $0.allPaths }

        self.file = project
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

    init(dict: Any, relativePath: Path) {
        if let sources = dict as? [String: [String]] {
            let include = sources["include"]?.map({ Path($0, relativeTo: relativePath) }) ?? []
            let exclude = sources["exclude"]?.map({ Path($0, relativeTo: relativePath) }) ?? []
            self.init(include: include, exclude: exclude)
        } else {
            let sources = (dict as? [String])?.map({ Path($0, relativeTo: relativePath) }) ?? []
            self.init(include: sources)
        }
    }

    init(include: [Path] = [], exclude: [Path] = []) {
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

    init(dict: [String: Any], relativePath: Path) {
        if let projects = dict["project"] as? [[String: Any]] {
            self = .projects(projects.flatMap({ Project.init(dict: $0, relativePath: relativePath) }))
        } else if let project = dict["project"] as? [String: Any] {
            self = .projects([Project(dict: project, relativePath: relativePath)].flatMap({ $0 }))
        } else {
            self = .sources(Paths(dict: dict["sources"], relativePath: relativePath))
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

    let source: Source
    let templates: Paths
    let output: Path
    let args: [String: NSObject]

    init(dict: [String: Any], relativePath: Path) {
        self.source = Source(dict: dict, relativePath: relativePath)
        self.templates = Paths(dict: dict, relativePath: relativePath)
        self.output = (dict["output"] as? String).map({ Path($0, relativeTo: relativePath) }) ?? "."
        self.args = dict["args"] as? [String: NSObject] ?? [:]
    }

    init(sources: [Path], templates: [Path], output: Path, args: [String: NSObject]) {
        self.source = .sources(Paths(include: sources))
        self.templates = Paths(include: templates)
        self.output = output
        self.args = args
    }

}
