import Foundation
import XcodeEdit
import PathKit

struct Project {
    let file: XCProjectFile
    let root: Path
    let targets: [Target]

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

    init?(dict: [String: Any]) {
        guard let file = dict["file"] as? String,
            let project = try? XCProjectFile(path: file),
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

        self.file = project
        self.root = Path(root)
    }

}

enum Source {
    case projects([Project])
    case sources([Path])

    init(dict: [String: Any]) {
        if let projects = dict["project"] as? [[String: Any]] {
            self = .projects(projects.flatMap(Project.init(dict:)))
        } else if let project = dict["project"] as? [String: Any] {
            self = .projects([Project(dict: project)].flatMap({ $0 }))
        } else {
            let sources = (dict["sources"] as? [String])?.map({ Path($0) }) ?? []
            self = .sources(sources)
        }
    }

    var isEmpty: Bool {
        switch self {
        case let .sources(sources):
            return sources.isEmpty
        case let .projects(projects):
            return projects.isEmpty
        }
    }
}

struct Configuration {

    let source: Source
    let templates: [Path]
    let output: Path
    let args: [String: NSObject]

    init(dict: [String: Any], relativePath: Path) {
        self.source = Source(dict: dict)
        let makePath = { (str: String) -> Path in
            let path = Path(str)
            if path.isAbsolute {
                return path
            } else {
                return (relativePath + path).absolute()
            }
        }
        self.templates = (dict["templates"] as? [String])?.map(makePath) ?? []
        self.output = (dict["output"] as? String).map(makePath) ?? "."
        self.args = dict["args"] as? [String: NSObject] ?? [:]
    }

    init(sources: [Path], templates: [Path], output: Path, args: [String: NSObject]) {
        self.source = Source.sources(sources)
        self.templates = templates
        self.output = output
        self.args = args
    }

}
